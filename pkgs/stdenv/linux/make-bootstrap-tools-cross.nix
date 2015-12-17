{ system ? builtins.currentSystem }:

let
  buildFor = toolsArch:
    let
      crossSystems = import ./cross-systems.nix;
      pkgsFun = import ../../top-level/all-packages.nix;
      pkgs = pkgsFun ({ inherit system; } // crossSystems.${toolsArch});
    in import ./make-bootstrap-tools-common.nix {
      inherit (pkgs) stdenv nukeReferences cpio binutilsCross;

      glibc = pkgs.libcCross;
      bash = pkgs.bash.crossDrv;
      findutils = pkgs.findutils.crossDrv;
      diffutils = pkgs.diffutils.crossDrv;
      gnused = pkgs.gnused.crossDrv;
      gnugrep = pkgs.gnugrep.crossDrv;
      gawk = pkgs.gawk.crossDrv;
      gnutar = pkgs.gnutar.crossDrv;
      gzip = pkgs.gzip.crossDrv;
      bzip2 = pkgs.bzip2.crossDrv;
      gnumake = pkgs.gnumake.crossDrv;
      patch = pkgs.patch.crossDrv;
      patchelf = pkgs.patchelf.crossDrv;
      gcc = pkgs.gcc.cc.crossDrv;
      gmpxx = pkgs.gmpxx.crossDrv;
      mpfr = pkgs.mpfr.crossDrv;
      ppl = pkgs.ppl.crossDrv;
      cloogppl = pkgs.cloogppl.crossDrv;
      cloog = pkgs.cloog.crossDrv;
      zlib = pkgs.zlib.crossDrv;
      isl = pkgs.isl.crossDrv;
      libmpc = pkgs.libmpc.crossDrv;
      binutils = pkgs.binutils.crossDrv;
      libelf = pkgs.libelf.crossDrv;
    };
in {
  armv5tel = buildFor "armv5tel";
  armv6l = buildFor "armv6l";
  armv7l = buildFor "armv7l";
}
