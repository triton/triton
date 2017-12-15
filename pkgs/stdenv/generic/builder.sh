# We need common utilities
# Since we are building a standard environment, our initialPath
# will contain these tools so we can use that
export PATH=""
for i in $initialPath; do
  PATH="$PATH${PATH:+:}$i/bin"
done

set -x

stdenvDir="$out"/share/stdenv
preFile="$stdenvDir"/10-pre.sh

mkdir -p "$stdenvDir"
echo "initialPath=\"$initialPath\"" >>"$preFile"
echo "$preHook" >>"$preFile"
for src in $setup; do
  # We want to get the actual filename without the nix hash
  name="$(basename "$src" | sed 's,^[^-]*-\(.*\)$,\1,')"
  cp -v "$src" "$stdenvDir"/"$name"
done
