#!/usr/bin/env bash
set -e
set -o pipefail

cd "$(dirname "$(readlink -f "$0")")"
source ./ipfs-common.sh

if ! ipfs >/dev/null 2>&1; then
  echo "Missing ipfs command"
  exit 1
fi

if ! ipfs swarm peers >/dev/null 2>&1; then
  echo "Ipfs daemon is not running"
  exit 1
fi

if ipfs pin ls -t direct | grep -q 'api version mismatch'; then
  echo "Got ipfs version mismatch" >&2
  exit 1
fi

cleanup() {
  CODE=$?
  rm -rf "$TMPDIR"
  trap - EXIT HUP INT QUIT PIPE TERM
  exit $CODE
}
TMPDIR="$(mktemp -d)"
trap cleanup EXIT HUP INT QUIT PIPE TERM

for var in "$@"; do
  if [ "$var" = "update" ]; then
    UPDATE_HASHLIST=1
  fi
done

export CONCURRENT_LOG_DIR=$TMPDIR/logs
export CONCURRENT_LIMIT=10
source concurrent.lib.sh

TOPDIR="$(pwd)"
while [ ! -d "$TOPDIR/pkgs" ]; do
  TOPDIR="$(dirname "$TOPDIR")"
done

cp pin-to-ipfs-hashes "$TMPDIR/hashes"
REV="$(cat pin-to-ipfs-rev)"
pushd "$TOPDIR" >/dev/null
while read obj; do
  echo "$obj" | git cat-file --batch | sed -n 's,.*"\(Qm[a-zA-Z0-9]*\)".*,\1,p' >> "$TMPDIR/hashes"
done < <(git rev-list "$REV"..HEAD --objects | grep '\.nix$' | awk '{print $1}')
popd >/dev/null
cat "$TMPDIR/hashes" | sort | uniq > "$TMPDIR/hashes.tmp"

if [ "$UPDATE_HASHLIST" = "1" ]; then
  if ! diff -q "$TMPDIR/hashes.tmp" pin-to-ipfs-hashes >/dev/null 2>&1; then
    cp "$TMPDIR/hashes.tmp" pin-to-ipfs-hashes
    git rev-list HEAD^..HEAD > pin-to-ipfs-rev
  fi
fi

declare -A current
while read h; do
  current["$h"]=1
done < <(ipfs pin ls -t recursive | awk '{print $1}' | sort | uniq)

fetch() {
  ipfs pin add --progress "$1"
}

cache() {
  local hash="$1"
  local gw="$2"

  set -x
  local out
  out="$(curl -L -N "$gw"/ipfs/"$hash" 2>&1 >&- || true)"
  if ! echo "$out" | grep -q 'Failed writing body (0 !='; then
    echo "$out"
    return 1
  fi
}

ARGS=()
pin_count=0
exec 3< "$TMPDIR/hashes.tmp"
while true; do
  if ! read HASH <&3; then
    break
  fi
  if [ "${current[$HASH]}" != "1" ]; then
    pin_name="Pin   $HASH"
    ARGS+=("-" "$pin_name" "fetch" "$HASH")
    for gw in "${RO_GATEWAYS[@]}"; do
      cache_name="Cache $HASH $gw"
      ARGS+=(
        "-" "$cache_name" "cache" "$HASH" "$gw"
        "--require" "$cache_name"
        "--before" "$pin_name"
      )
    done
    pin_count=$(( $pin_count + 1 ))
  fi
  if [ "$pin_count" -ge "20" ]; then
    concurrent "${ARGS[@]}"
    ARGS=()
    pin_count=0
  fi
done
exec 3<&-
if [ "${#ARGS[@]}" -gt "0" ]; then
  concurrent "${ARGS[@]}"
fi
