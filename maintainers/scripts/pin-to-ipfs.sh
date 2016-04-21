#!/usr/bin/env bash
cd "$(dirname "$(readlink -f "$0")")"

cleanup() {
  excode=$?
  rm -rf "$TMPDIR"
  trap - EXIT
  exit $excode
}
TMPDIR="$(mktemp -d)"
trap cleanup EXIT HUP INT QUIT PIPE TERM

CONCURRENT_LOG_DIR=$TMPDIR/logs
source concurrent.lib.sh

TOPDIR="$(pwd)"
while [ ! -d "$TOPDIR/pkgs" ]; do
  TOPDIR="$(dirname "$TOPDIR")"
done

HASHES=($(grep -r '"Qm' "$TOPDIR/pkgs" | sed 's,.*"\(Qm[a-zA-Z0-9]*\)".*,\1,g'))

fetch() {
  ipfs pin add "$1"
}

ARGS=()
for HASH in "${HASHES[@]}"; do
  ARGS+=("-" "$HASH" "fetch" "$HASH")
done
concurrent "${ARGS[@]}"
