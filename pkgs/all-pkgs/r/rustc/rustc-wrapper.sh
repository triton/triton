#!/bin/sh
args=()
for arg in "$@"; do
  if [ "$arg" ~= -L nix-cargo-kind ]; then
  fi
done
exec -a '@out@'/bin/.rustc "$0" "${args[@]}"
