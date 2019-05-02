#!/usr/bin/env bash

updater="$(dirname "$(readlink -f "$0")")/update-go-package.sh"

# Find the top git level
while ! [ -d "pkgs/top-level" ]; do
  cd ..
done

exec "$updater" $(cat pkgs/top-level/all-packages.nix | grep 'pkgs\.goPackages\..*\.bin' | awk -F. '{print $3}' | tr '\n' ' ')
