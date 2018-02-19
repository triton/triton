set -e
set -o pipefail

export PATH="$bootstrap/bin"

if [ -n "$bin" ]; then
  output=bin
else
  output=out
fi

link() {
  local bin="$1"

  if [ ! -e "$bootstrap"/bin/"$bin" ]; then
    echo "Missing $bootstrap/bin/$bin"
    return 1
  fi

  mkdir -p "${!output}"/bin
  ln -sv "$bootstrap"/bin/"$bin" "${!output}"/bin
}

if [ -n "$setupHook" ]; then
  mkdir -p "${!output}"/nix-support
  sed "s,@$output@,${!output}," <"$setupHook" >"${!output}"/nix-support/setup-hook
fi

if [ -n "$extraCmd" ]; then
  eval "$extraCmd"
fi

