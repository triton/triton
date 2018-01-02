set -e
set -o pipefail

export PATH="$bootstrap/bin"

link() {
  local bin="$1"

  if [ ! -e "$bootstrap"/bin/"$bin" ]; then
    echo "Missing $bootstrap/bin/$bin"
    return 1
  fi

  mkdir -p "$out"/bin
  ln -sv "$bootstrap"/bin/"$bin" "$out"/bin
}

if [ -n "$setupHook" ]; then
  mkdir -p "$out"/nix-support
  sed "s,@out@,$out," <"$setupHook" >"$out"/nix-support/setup-hook
fi

if [ -n "$extraCmd" ]; then
  eval "$extraCmd"
fi

