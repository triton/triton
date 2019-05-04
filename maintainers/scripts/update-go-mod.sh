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

declare -a -r generated=(
  'go.mod'
  'go.sum'
  'source.json'
)

# Setup the temporary storage area
TMPDIR=""
cleanup() {
  CODE="$?"
  mkdir -p "$TMPDIR"/safe
  if [ -z "$DONT_RESTORE" ]; then
    for pkg in $(ls "$TMPDIR"/safe); do
      drv_dir="$(get_drv_dir "$pkg")"
      for file in "${generated[@]}"; do
        if [ "$(readlink -f "$TMPDIR"/safe/"$pkg"/"$file")" = "/dev/null" ]; then
          rm "$drv_dir"/"$file"
        elif [ -f "$TMPDIR"/safe/"$pkg"/"$file" ]; then
          mv "$TMPDIR"/safe/"$pkg"/"$file" "$drv_dir"/"$file"
        fi
      done
    done
  fi
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

get_drv_dir() {
  echo "$TOP_LEVEL/pkgs/all-pkgs/${1:0:1}/$1"
}

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

do_mod_update() {
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

  # Create a new module if our project doesn't support yet
  if [ ! -f go.mod ]; then
    go mod init
  fi

  # Get rid of any replacements the developers think work
  sed -i '/replace/d' go.mod

  # Update the deps if we need to
  if [ "$updateDeps" != "false" ]; then
    echo "Updating dependencies" >&3
    go get -d -u
  else
    echo "Skipping dependency update" >&3
  fi

  # Clean up any stale modules or populate empty modfile
  echo "Tidying the module" >&3
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
  echo "Update Needed" >&3
  cp go.{mod,sum} "$drv_dir"
  exec 10>"$drv_dir"/source.json
  echo '{' >&10
  echo "  \"fetchzipVersion\": $FETCHZIP_VERSION," >&10
  echo "  \"rev\": \"$version\",">&10
  echo "  \"sha256\": \"$BAD_SHA256\"," >&10
  echo "  \"version\": \"$version\"">&10
  echo '}' >&10
  exec 10>&-
  echo 'fetch_source'
}

update_sha256() {
  local sha256="$1"

  jq ".sha256 = \"$sha256\"" "$drv_dir"/source.json >"$TMPDIR"/"$pkg".json
  mv "$TMPDIR"/"$pkg".json "$drv_dir"/source.json
}

do_mod_rehash() {
  update_sha256 "$BAD_SHA256"
  echo 'fetch_source'
}

do_update() {
  local pkg="$1"

  local drv_dir
  drv_dir="$(get_drv_dir "$pkg")"
  test -d "$drv_dir"

  if ! [ -f "$drv_dir"/target.json ]; then
    echo "Missing target.json" >&3
    return 0
  fi

  # Save the old generated files in case we error out
  mkdir -p "$TMPDIR"/safe/"$pkg"
  for file in "${generated[@]}"; do
    if test -f "$drv_dir"/"$file"; then
      cp "$drv_dir"/"$file" "$TMPDIR"/safe/"$pkg"/"$file"
    else
      ln -s /dev/null "$TMPDIR"/safe/"$pkg"/"$file"
    fi
  done

  # Do source file regeneration and update
  local fetch_source=""
  if [ -n "$DO_REHASH" ]; then
    fetch_source="$(do_mod_rehash)"
  elif [ "$(jq -r '.skipUpdate' "$drv_dir"/target.json)" = "true" ]; then
    echo "Automatic Update Skipped" >&3
  elif [ -z "$SKIP_UPDATE" ]; then
    fetch_source="$(do_mod_update)"
  fi

  # Leverage the source fetcher to determine our new hash
  if [ -n "$fetch_source" ]; then
    echo "Updating source hash" >&3
    mkdir -p "$TMPDIR/log"
    nix-build -A pkgs.$pkg.src "$TOP_LEVEL" --no-out-link 2>&1 | tee "$TMPDIR"/log/"$pkg" || true
    sha256=$(grep 'got:[ ]*sha256:' "$TMPDIR"/log/"$pkg" | awk -F: '{print $3}')
    test -n "$sha256"
    update_sha256 "$sha256"
    DO_BUILD=1
  fi

  if [ -n "$DO_BUILD" ]; then
    echo "Building package" >&3
    nix-build -A pkgs.$pkg "$TOP_LEVEL" --no-out-link
  fi

  # Ensure we don't restore old files now
  for file in "${generated[@]}"; do
    rm -f "$TMPDIR"/safe/"$pkg"/"$file"
  done
}

ARGS=()
for pkg in "$@"; do
  if [ "$pkg" = "*" ]; then
    for pkg in $(grep '= callPackage ../all-pkgs' "$TOP_LEVEL"/pkgs/top-level/go-packages.nix | grep -v 'GoMod' | awk '{print $1}'); do
      ARGS+=('-' "Update $pkg" do_update "$pkg")
    done
  else
    ARGS+=('-' "Update $pkg" do_update "$pkg")
  fi
done
concurrent "${ARGS[@]}"
