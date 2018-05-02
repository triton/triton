#!/usr/bin/env bash
pkgs=(
  stdenv
  stdenv.stdenvDeps
)
arches=(
  i686-linux
  x86_64-linux
)
args=()
for pkg in "${pkgs[@]}"; do
  args+=(-A pkgs."$pkg".all)
done
set -x
for arch in "${arches[@]}"; do
  nix-build "${args[@]}" -o "result-${arch}" --argstr targetSystem "$arch" --argstr hostSystem "$arch" &
done
wait
