{ targetSystem ? builtins.currentSystem
, hostSystem ? builtins.currentSystem
}:

let
  pkgs = import ../../.. { inherit targetSystem hostSystem; };

  a = import ./make-bootstrap-tools-common.nix ({
    inherit (pkgs)
      stdenv
      nukeReferences
      cpio
      glibc
      patchelf
      binutils;
    busybox = pkgs.busyboxBootstrap;
    gcc = pkgs.gcc.cc;
    readelf = "${pkgs.binutils}/bin/readelf";
  } // (import ../generic/common-path.nix { inherit pkgs; }));
in a
