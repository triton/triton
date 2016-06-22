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

HASHES=($(grep -r '"Qm' "$TOPDIR/pkgs" | sed 's,.*"\(Qm[a-zA-Z0-9]*\)".*,\1,g' | sort | uniq))

declare -A current
while read h; do
  current["$h"]=1
done < <(ipfs pin ls -t recursive | awk '{print $1}' | sort | uniq)

fetch() {
  ipfs pin add "$1"
}

ARGS=()
for HASH in "${HASHES[@]}"; do
  if [ "${current[$HASH]}" != "1" ]; then
    ARGS+=("-" "$HASH" "fetch" "$HASH")
  fi
done
if [ "${#ARGS[@]}" -gt "0" ]; then
  concurrent "${ARGS[@]}"
fi
