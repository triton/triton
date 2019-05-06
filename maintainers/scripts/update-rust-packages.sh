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
  'deps.json'
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
TMPDIR="$(mktemp -d /tmp/update-rust.XXXXXXXXXX)"

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
  name = \"update-rust-env\";
  paths = with pkgs; [
    coreutils_small
    curl_minimal
    diffutils
    gawk_small
    git
    gnugrep
    gnused_small
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

do_source_update() {
  # Get the target information
  local package
  package="$(jq -r '.package' "$drv_dir"/target.json)"
  local target
  target="$(jq -r '.version' "$drv_dir"/target.json)"

  # Get the source information
  echo "Getting new source info" >&3
  local info
  info="$(curl -L "https://crates.io/api/v1/crates/$package")"
  local h
  if [ "$target" = "latest" ]; then
    local version
    version="$(echo "$info" | jq -r '.crate.max_version')"
    h="sha256:$(curl -L "https://crates.io/api/v1/crates/$package/$version/download" | sha256sum | awk '{ print $1 }')"
  elif [ "$target" = "master" ]; then
    echo "$info" | jq '.crate.repository' >&2
    echo "UNSUPPORTED" >&2
    return 1
  else
    echo "Invalid Target: $target" >&2
    return 1
  fi

  # Generate the source definition
  jq "$drv_dir"/source.json 2>/dev/null || echo '{}' >"$drv_dir"/source.json
  jq --arg package "$package" --arg version "$version" --arg hash "$h" \
    '.package = $package | .version = $version | .hash = $hash' "$drv_dir"/source.json >"$TMPDIR"/"$pkg".json
  mv "$TMPDIR"/"$pkg".json "$drv_dir"/source.json
  echo 'fetch_deps'
}

update_dep_hash() {
  local hash="$1"

  jq ".hash = \"$hash\"" "$drv_dir"/deps.json >"$TMPDIR"/"$pkg".json
  mv "$TMPDIR"/"$pkg".json "$drv_dir"/deps.json
}

do_dep_rehash() {
  update_dep_hash "sha256:$BAD_SHA256"
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
  local fetch_deps=""
  if [ "$(jq -r '.skipUpdate' "$drv_dir"/target.json)" = "true" ]; then
    echo "Automatic Update Skipped" >&3
  else
    fetch_deps="$(do_source_update)"
  fi

  # Leverage the deps fetcher to determine our new hash
  local needs_update=""
  if [ -n "$fetch_deps" ]; then
    echo "Updating deps hash" >&3

    # Save the old hash if it exists
    local oldh
    oldh="$(jq -r '.hash' "$drv_dir"/deps.json 2>/dev/null || true)"

    # Write the data needed to compute the deps
    jq "$drv_dir"/deps.json 2>/dev/null || echo '{}' >"$drv_dir"/deps.json
    jq --arg zipVersion "$FETCHZIP_VERSION" --arg crates_rev "$CRATES_INDEX_REV" --arg crates_hash "$CRATES_INDEX_HASH" --arg hash "sha256:$BAD_SHA256"  \
      '.zipVersion = $zipVersion | ."crates-rev" = $crates_rev | ."crates-hash" = $crates_hash | .hash = $hash' "$drv_dir"/deps.json >"$TMPDIR"/"$pkg".json
    mv "$TMPDIR"/"$pkg".json "$drv_dir"/deps.json

    # Perform the build of the deps
    mkdir -p "$TMPDIR/log"
    nix-build -A pkgs.rustPackages."$pkg".CARGO_DEPS "$TOP_LEVEL" --no-out-link 2>&1 | tee "$TMPDIR"/log/"$pkg" || true
    h="$(tac "$TMPDIR"/log/"$pkg" | grep -m 1 '\(Hash\|got\):' | awk '{print $2}')"
    update_dep_hash "$h"

    # Determine if the package is up to date
    if [ "$oldh" != "$h" ] || ! cmp "$TMPDIR"/safe/"$pkg"/source.json "$drv_dir"/source.json; then
      DO_BUILD=${DO_BUILD-1}
      needs_update=1
    fi
  fi

  if [ -n "$DO_BUILD" ]; then
    echo "Building package" >&3
    nix-build -A pkgs.rustPackages."$pkg" "$TOP_LEVEL" --no-out-link
  fi

  # Ensure we don't restore old files now
  if [ -n "$needs_update" ]; then
    echo "Updated" >&3
    for file in "${generated[@]}"; do
      rm -f "$TMPDIR"/safe/"$pkg"/"$file"
    done
  else
    echo "No Update Needed" >&3
  fi
}

echo "Updating crates index..." >&2
CRATES_INDEX_REV="$(git ls-remote https://github.com/rust-lang/crates.io-index refs/heads/master | awk '{ print $1 }')"
exp="let pkgs = import ./. { };
in pkgs.fetchFromGitHub {
  version = $FETCHZIP_VERSION;
  owner = \"rust-lang\";
  repo = \"crates.io-index\";
  rev = \"$CRATES_INDEX_REV\";
  hash = \"sha256:$BAD_SHA256\";
}"
nix-build --no-out-link -E "$exp" >"$TMPDIR"/log-index 2>&1 || true
CRATES_INDEX_HASH="$(tac "$TMPDIR"/log-index | grep -m 1 '\(Hash\|got\):' | awk '{print $2}')"
ARGS=()
for pkg in "$@"; do
  if [ "$pkg" = "*" ]; then
    for pkg in $(grep '= callPackage ../all-pkgs' "$TOP_LEVEL"/pkgs/top-level/rust-packages.nix | grep -v '\(Crate\|Cargo\| rust-std\| rustc\| cargo\)' | awk '{print $1}'); do
      ARGS+=('-' "Update $pkg" do_update "$pkg")
    done
  else
    ARGS+=('-' "Update $pkg" do_update "$pkg")
  fi
done
concurrent "${ARGS[@]}"
