{ targetSystem ? builtins.currentSystem
, hostSystem ? builtins.currentSystem
}:

let
  pkgs = import ../../.. { inherit targetSystem hostSystem; };

  a = import ./make-bootstrap-tools-common.nix {
    inherit (pkgs)
      bash_small
      binutils
      busybox_bootstrap
      bzip2
      coreutils_small
      diffutils
      findutils
      gawk_small
      glibc_lib_gcc
      gcc
      gcc_lib_glibc
      gcc_runtime_glibc
      gnugrep
      gnumake
      gnupatch_small
      gnused_small
      gnutar_small
      gzip
      linux-headers
      patchelf
      nukeReferences
      stdenv
      xz;
  };
in a
