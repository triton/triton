export PATH=""
for i in $initialPath; do
  PATH="$PATH${PATH:+:}$i/bin"
done

mkdir -p "$out"

echo "initialPath=\"$initialPath\"" >>"$out"/setup
echo "defaultNativeBuildInputs=\"$defaultNativeBuildInputs\"" >>"$out"/setup
echo "$preHook" >>"$out"/setup
for src in $setup; do
  cat "$src" >>"$out"/setup
done

# Allow the user to install stdenv using nix-env and get the packages
# in stdenv.
mkdir -p "$out"/nix-support
echo $propagatedUserEnvPkgs >"$out"/nix-support/propagated-user-env-packages
