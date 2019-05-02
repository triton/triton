#!/usr/bin/env bash
set -o pipefail
set -e

if [ "0" -eq "$#" ]; then
  echo "Takes at least one argument, the list of packages to update." >&2
  exit 1
fi

BAD_SHA256="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

# Parameters to conform to fetchzip versioning
FETCHZIP_VERSION=6

# Setup the temporary storage area
TMPDIR=""
cleanup() {
  CODE="$?"
  echo "Cleaning up..." >&2
  if [ -n "$TMPDIR" ]; then
    rm -rf "$TMPDIR"
  fi
  trap - EXIT ERR INT QUIT PIPE TERM
  exit "$CODE"
}
trap cleanup EXIT ERR INT QUIT PIPE TERM
TMPDIR="$(mktemp -d /tmp/update-go-mod.XXXXXXXXXX)"

# Include the concurrent library
cd "$(readlink -f "$0" | xargs dirname)"
source concurrent.lib.sh
CONCURRENT_LOG_DIR="$TMPDIR/logs"

# Find the top git level
while ! [ -d "pkgs/top-level" ]; do
  cd ..
done
TOP_LEVEL="$(pwd)"

# Build all of the packages needed to run this script
echo "Building script dependencies..." >&2
exp="let pkgs = import ./. { };
in pkgs.buildEnv {
  name = \"update-go-module-env\";
  paths = with pkgs; [
    coreutils_small
    diffutils
    gawk_small
    git
    gnugrep
    gnused_small
    go
    jq
    ncurses
  ];
}"
if ! nix-build --out-link "$TMPDIR"/nix-env -E "$exp" >/dev/null; then
  echo "Failed to build dependencies of this script" >&2
  exit 1
fi
NIX_BIN="$(dirname "$(type -tP nix-build)")"
mkdir -p "$TMPDIR"/bin
ln -s "$NIX_BIN"/nix-build "$TMPDIR"/bin
export PATH="$(readlink -f "$TMPDIR/nix-env")/bin:$TMPDIR/bin"

# Clean up our go environment
unset GOPATH
unset GOROOT
export GO11MODULE=on

do_update() {
  local pkg="$1"

  local drv_dir
  drv_dir="$TOP_LEVEL/pkgs/all-pkgs/${pkg:0:1}/$pkg"
  test -d "$drv_dir"

  # Get the target information
  local updateDeps
  updateDeps="$(jq -r '.updateDeps' "$drv_dir"/target.json)"
  local path
  path="$(jq -r '.path' "$drv_dir"/target.json)"
  local target
  target="$(jq -r '.version' "$drv_dir"/target.json)"

  # Do the initial source fetch
  local srcDir="$TMPDIR/src/$pkg"
  mkdir -p "$srcDir"
  pushd "$srcDir" >/dev/null
  go mod init src 2>/dev/null
  echo "Fetching module" >&3
  # Ignore errors during get due to go spuriously telling us we can't build
  # This will be fine, since we check the output files
  go get -d "$path@$target" || true
  local version
  version="$(go list -m "$path" | awk '{print $2}')"
  echo "Using version: $version" >&3
  popd >/dev/null
  rm -r "$srcDir"

  # Get the real source we fetched
  cp -r --no-preserve all "$HOME"/go/pkg/mod/"$path@$version" "$srcDir"
  pushd "$srcDir" >/dev/null

  # Get rid of any replacements the developers think work
  sed -i '/replace/d' go.mod

  # Update the deps if we need to
  if [ "$updateDeps" != "false" ]; then
    echo "Updating dependencies" >&3
    go get -d -u
  else
    echo "Skipping dependency update" >&3
  fi

  # Clean up any stale modules
  go mod tidy

  # Determine if our old info was up to date
  local oldVersion=""
  oldVersion="$(jq -r '.rev' "$drv_dir"/source.json)" || true
  local oldFV=""
  oldFV="$(jq -r '.fetchzipVersion' "$drv_dir"/source.json)" || true
  local oldSha256=""
  oldSha256="$(jq -r '.sha256' "$drv_dir"/source.json)" || true
  if [ "$oldFV" = "$FETCHZIP_VERSION" ] &&
      [ "$oldVersion" = "$version" ] &&
      [ "$oldSha256" != "$BAD_SHA256" ] &&
      cmp go.mod "$drv_dir"/go.mod &&
      cmp go.sum "$drv_dir"/go.sum; then
    echo "No Update Needed" >&3
    return 0
  fi

  # Generate the source definition
  echo "Updating source hash" >&3
  cp go.{mod,sum} "$drv_dir"
  exec 10>"$drv_dir"/source.json
  echo '{' >&10
  echo "  \"fetchzipVersion\": $FETCHZIP_VERSION," >&10
  echo "  \"rev\": \"$version\",">&10
  echo "  \"sha256\": \"$BAD_SHA256\"," >&10
  echo "  \"version\": \"$version\"">&10
  echo '}' >&10
  exec 3>&-

  # Leverage the source fetcher to determine our new hash
  mkdir -p "$TMPDIR/log"
  nix-build -A pkgs.$pkg.src "$TOP_LEVEL" 2>&1 | tee "$TMPDIR"/log/"$pkg" || true
  sha256=$(grep 'got:[ ]*sha256:' "$TMPDIR"/log/"$pkg" | awk -F: '{print $3}')
  sed -i "/sha256/s,: \".*\",: \"$sha256\"," "$drv_dir"/source.json
}

ARGS=()
for pkg in "$@"; do
  ARGS+=('-' "Update $pkg" do_update "$pkg")
done
concurrent "${ARGS[@]}"
