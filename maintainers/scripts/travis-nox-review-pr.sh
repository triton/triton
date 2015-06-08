#!/usr/bin/env bash
set -e

export NIX_CURL_FLAGS="-sS"

case "$1" in
    'nix')
        echo "=== Installing Nix..."
        # Install Nix
        bash <(curl -sS https://nixos.org/nix/install)
        source $HOME/.nix-profile/etc/profile.d/nix.sh

        # Configure Nix to make sure we can use hydra's binary cache
        sudo mkdir "/etc/nix"
        (sudo cat <<NIXCONFIG
binary-caches = http://cache.nixos.org http://hydra.nixos.org
trusted-binary-caches = http://hydra.nixos.org
build-max-jobs = 4
NIXCONFIG
) > "/etc/nix/nix.conf"

        # Verify evaluation
        echo "=== Verifying that nixpkgs evaluates..."
        nix-env -f. -qa --json > /dev/null
    ;;
    'nox')
        echo "=== Installing nox..."
        git clone -q "https://github.com/madjar/nox"
        pip --quiet install -e nox
    ;;
    'build')
        source $HOME/.nix-profile/etc/profile.d/nix.sh

        if [ "$TRAVIS_PULL_REQUEST" == "false" ] ; then
            echo "=== Not a pull request"
        else
            echo "=== Checking PR"
            nox-review pr "$TRAVIS_PULL_REQUEST"
        fi

        # echo "=== Checking tarball creation"
        # nix-build pkgs/top-level/release.nix -A tarball
    ;;
    *)
        echo "$0: Unknown option $1" >&2
        exit 1
    ;;
esac

exit 0
