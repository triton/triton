set -e
set -o pipefail
set -u

source "$NIX_BUILD_TOP"/.attrs.sh

export PATH=
for i in "${initialPath[@]}"; do
  PATH=$PATH${PATH:+:}${i%/}/bin
done

mkdir "${outputs[out]}"
echo "export SHELL=${shell}" > "${outputs[out]}"/setup
echo "$(declare -p initialPath)" >> "${outputs[out]}"/setup
echo "$(declare -p defaultNativeBuildInputs)" >> "${outputs[out]}"/setup
echo "$(declare -p defaultBuildInputs)" >> "${outputs[out]}"/setup
echo "${preHook}" >> "${outputs[out]}"/setup
cat "${setup}" >> "${outputs[out]}"/setup

# Allow the user to install stdenv using nix-env and get the packages
# in stdenv.
mkdir "${outputs[out]}"/nix-support
echo "${propagatedUserEnvPkgs[*]}" > "${outputs[out]}"/nix-support/propagated-user-env-packages
