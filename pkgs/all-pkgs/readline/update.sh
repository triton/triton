#! /bin/sh
set -o pipefail
set -e

# Get the current directory containing the nix expressions
NIX_DIR="$(dirname "$(readlink -f "$0")")"

source $NIX_DIR/../../development/tools/godep/concurrent.lib.sh

# Setup the temporary storage area
TMPDIR=""
cleanup() {
  CODE="$?"
  echo "Cleaning up..." >&2
  if [ -n "$TMPDIR" ]; then
    rm -rf "$TMPDIR"
  fi
  exit "$?"
}
trap cleanup EXIT ERR INT QUIT PIPE TERM
TMPDIR="$(mktemp -d)"

cd "$TMPDIR"

# Figure out which tarball to use
generate_tarball_info() {
  curl -L "https://ftp.gnu.org/gnu/readline" \
    | sed 's,<a[^>]*>\(.*\)</a>,\n\1\n,g' \
    | sed '/[<>]/d' \
    | grep 'readline-[0-9.]*\.tar' \
    | sed 's,.*readline-\([0-9.]*\)\.tar\.\([^.]*\).*,\1 \2,g' \
    | sort -V \
    | tail -n 1 > tarball-info
}
concurrent "-" "Generating tarball info" generate_tarball_info

VERSION="$(cat tarball-info | awk '{print $1}')"
COMPRESS="$(cat tarball-info | awk '{print $2}')"

echo "         - Latest version: $VERSION"
echo "         - Compression mode: $COMPRESS"

generate_patch_info() {
  curl -L "https://ftp.gnu.org/gnu/readline/readline-$VERSION-patches" \
    | sed 's,<a[^>]*>\(.*\)</a>,\n\1\n,g' \
    | sed '/[<>]/d' \
    | grep 'readline' \
    | grep -v 'sig' > patch-info
}
concurrent "-" "Generating patcheset info" generate_patch_info

download_from_readline() {
  curl -O -L "https://ftp.gnu.org/gnu/readline/$1"
}

gpg2 -o "key.gpg" --dearmor "$NIX_DIR/gpgkey.asc" 2>/dev/null
validate_and_hash() {
  gpg2 --no-default-keyring --keyring "./key.gpg" --verify "$1"{.sig,}
  HASH="$(nix-hash --flat --type sha256 --base32 "$1")"

  exec 3<>"$2.lock"
  flock -x 3
  echo "$1 $HASH" >> "$2"
  exec 3>&-
}

add_tarball_arguments() {
  ARGS+=(
    "-" "Download $2" "download_from_readline" "$3/$2"
    "-" "Download $2.sig" "download_from_readline" "$3/$2.sig"
    "-" "Verify   $2" "validate_and_hash" "$2" "$1"
    "--require" "Download $2"
    "--require" "Download $2.sig"
    "--before" "Verify   $2"
  )
}

ARGS=()
add_tarball_arguments "tarball" "readline-$VERSION.tar.$COMPRESS"
for patch in $(cat patch-info); do
  add_tarball_arguments "patches" "$patch" "readline-$VERSION-patches"
done
concurrent "${ARGS[@]}"

sed -i "s,sha256 = \".*\";,sha256 = \"$(awk '{print $2}' tarball)\";,g" $NIX_DIR/default.nix
sort -V patches | awk '
BEGIN {
  print "{";
}
{
  print "  \""$1"\" = \""$2"\";";
}
END {
  print "}";
}' > $NIX_DIR/patches.nix
