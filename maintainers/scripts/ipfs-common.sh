RW_GATEWAYS=(
  #"https://ipfs.works"
  #"https://ipfs.work"
)
RO_GATEWAYS=(
  "https://ipfs.io"
  #"https://hardbin.com"
  "https://ipfs.wak.io"
)

can_use_ipfs() {
  if ! ipfs >/dev/null 2>&1; then
    echo "Missing ipfs command" >&2
    return 1
  fi

  if ! ipfs swarm peers >/dev/null 2>&1; then
    echo "Ipfs daemon is not running" >&2
    return 1
  fi

  if ipfs pin ls -t direct | grep -q 'api version mismatch'; then
    echo "Got ipfs version mismatch" >&2
    return 1
  fi

  return 0
}

