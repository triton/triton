{ system ? builtins.currentSystem }:

let
  pkgs = import ../../top-level/all-packages.nix { inherit system; };
  a = import ./make-bootstrap-tools-common.nix {
    inherit (pkgs) stdenv nukeReferences cpio;
    readelf = "${pkgs.binutils}/bin/readelf";
    inherit (pkgs) glibc coreutils bash findutils diffutils gnused gnugrep gawk gnutar
      gzip bzip2 xz gnumake patch patchelf curl pkgconfig binutils libmpc;
    gcc = pkgs.gcc.cc;
    busybox = pkgs.busyboxBootstrap;
  };
in a // {
  test = ((import ./default.nix) {
    inherit system;

    customBootstrapFiles = {
      busybox = "${a.build}/on-server/busybox";
      bootstrapTools = "${a.build}/on-server/bootstrap-tools.tar.xz";
    };
  }).testBootstrapTools;
}
