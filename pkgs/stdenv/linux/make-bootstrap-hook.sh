set -e
set -o pipefail

PATH="$bootstrap/bin"

mkdir -p "$out"/{bin,nix-support}
ln -sv "$bootstrap"/bin/"$bin" "$out"/bin
sed "s,@out@,$out," <"$setupHook" >"$out"/nix-support/setup-hook
if [ -n "$extraCmd" ]; then
  eval "$extraCmd"
fi
