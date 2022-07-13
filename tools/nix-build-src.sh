#!/usr/bin/env bash
set -o pipefail
set -e

if [ "$1" = "-A" ]; then
  shift
fi
pkg="$1"

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

# Find the top level of nixpkgs
cd "$(readlink -f "$0" | xargs dirname)"
while ! [ -d "pkgs/top-level" ]; do
  cd ..
done
TOP_LEVEL="$(pwd)"

echo "Instantiating: $pkg" >&2
nix-instantiate --add-root "$TMPDIR/instance" --indirect './.' -A "$pkg" >/dev/null

echo "Finding all of the needed srcs: $pkg" >&2
declare -A processed
process=("$(readlink -f "$TMPDIR/instance")")
srcs=()

while [ "${#process[@]}" -gt "0" ]; do
  new=()
  if [ "${processed["${process[0]}"]}" != "1" ]; then
    contents="$(cat "${process[0]}")"
    new=($(echo "$contents" | tr '"' '\n' | grep '^/[^ ]*.drv$' || true))
    if echo "$contents" | grep -q 'outputHashAlgo'; then
      srcs+=("${process[0]}")
    fi
  fi
  processed["${process[0]}"]=1
  process=("${process[@]:1}" "${new[@]}")
done

echo "Realizing the srcs: $pkg" >&2
echo "nix-store -k -r" "${srcs[@]}" >&2
nix-store -k -r "${srcs[@]}"
