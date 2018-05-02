#!/usr/bin/env bash
pkgs=(
  curl
  curl_minimal
  cmake
  autoconf
  automake
  '(deterministic-zip.override { version = 6; })'
  libtool
  goPackages.go
  gnum4
  gnupg
  ninja
  meson
  autogen
  libxslt
  libxml2
  yasm
  nasm
  git
  gettext
  bison
  flex
  googletest
  valgrind
  gdb
  llvm
  asciidoctor_1
  asciidoctor_2
  xmlto
  docbook-xsl
  intltool
  vala
  python2
  python3
  perl
  rustPackages.cargo
  rustPackages.cargo-vendor
  rustPackages.rustc
  rustPackages.rust-std
  strace
  unzip
  unrar
  itstool
  iasl
  nix
  textencode
  jq
  texinfo
  groff
  ruby
)
args=()
for pkg in "${pkgs[@]}"; do
  args+=(-E "with (import ./default.nix { }).pkgs; $pkg.all")
done
set -x
exec nix-build "${args[@]}" "$@"
