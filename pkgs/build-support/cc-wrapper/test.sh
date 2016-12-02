#!/bin/bash
set -e
set -x
cd "$(dirname "$(readlink -f "$0")")"
. utils.sh

badPath "/no-such-path/hi"
! badPath "/no/hi"
! badPath "/hello/world"
NIX_ENFORCE_PURITY=1
badPath "/hello/world"
! badPath "/nix/store/hi"
! badPath "/tmp/hi"
