# This file constructs the standard build environment for the
# Linux/i686 platform.  It's completely pure; that is, it relies on no
# external (non-Nix) tools, such as /usr/bin/gcc, and it contains a C
# compiler and linker that do not search in default locations,
# ensuring purity of components produced by it.

# The function defaults are for easy testing.
{ system ? builtins.currentSystem
, allPackages ? import ../../top-level/all-packages.nix
, platform ? null, config ? {}, lib ? (import ../../../lib)
, customBootstrapFiles ? null }:

rec {

  bootstrapFiles =
    if customBootstrapFiles != null then customBootstrapFiles
    else if system == "i686-linux" then import ./bootstrap/i686.nix
    else if system == "x86_64-linux" then import ./bootstrap/x86_64.nix
    else if system == "armv5tel-linux" then import ./bootstrap/armv5tel.nix
    else if system == "armv6l-linux" then import ./bootstrap/armv6l.nix
    else if system == "armv7l-linux" then import ./bootstrap/armv7l.nix
    else if system == "mips64el-linux" then import ./bootstrap/loongson2f.nix
    else abort "unsupported platform for the pure Linux stdenv";


  commonStdenvOptions = {
    inherit system config;

    preHook = ''
      export NIX_ENFORCE_PURITY=1
      # Make "strip" produce deterministic output, by setting
      # timestamps etc. to a fixed value.
      export commonStripFlags="--enable-deterministic-archives"
    '';
  };


  # The bootstrap process proceeds in several steps.


  # Create a standard environment by downloading pre-built binaries of
  # coreutils, GCC, etc.


  # Download and unpack the bootstrap tools (coreutils, GCC, Glibc, ...).
  bootstrapTools = derivation {
    name = "bootstrap-tools";

    builder = bootstrapFiles.busybox;

    args = [ "ash" "-e" ./scripts/unpack-bootstrap-tools.sh ];

    tarball = bootstrapFiles.bootstrapTools;

    inherit system;
    inherit (bootstrapFiles) langC langCC isGNU;

    outputs = [ "out" "glibc" ];
  };

  bootstrapShell = "${bootstrapTools}/bin/sh";

  bootstrapToolsTest = derivation {
    name = "bootstrap-tools";

    builder = bootstrapFiles.busybox;

    args = [ "ash" "-e" ./scripts/unpack-bootstrap-tools-test.sh ];

    tarball = bootstrapFiles.bootstrapTools;

    inherit system;
    inherit (bootstrapFiles) langC langCC isGNU;
  };

  commonBootstrapOptions = {
    shell = bootstrapShell;
    initialPath = [ bootstrapTools ];
    extraBuildInputs = [ ];

    preHook = ''
      # We don't want to patch shebangs as this will retain references to the
      # bootstra tools.
      export dontPatchShebangs=1
    '';

  };

  # This is not a real set of packages or stdenv.
  # This is just enough for us to use stdenv.mkDerivation to build our
  # first cc-wrapper and fetchurlBoot.
  # This does not provide any actual packages.
  stage0Pkgs = allPackages {
    inherit system platform;
    bootStdenv = import ../generic (commonStdenvOptions // commonBootstrapOptions // {
      name = "stdenv-linux-boot-stage0";

      cc = null;

      overrides = pkgs: (lib.mapAttrs (n: _: throw "Tried to access ${n}") pkgs) // {
        inherit (pkgs) stdenv;

        fetchurl = import ../../build-support/fetchurl {
          stdenv = stage0Pkgs.stdenv;
          curl = bootstrapTools;
        };

        patchelf = stage0Pkgs.stdenv.mkDerivation {
          name = "patchelf-boot";
          src = bootstrapTools;
          installPhase = ''
            mkdir -p $out/bin
            ln -s $bootstrapTools/bin/patchelf $out/bin
          '';
          setupHook = ../../development/tools/misc/patchelf/setup-hook.sh;
        };

        gcc = lib.makeOverridable (import ../../build-support/cc-wrapper) {
          nativeTools = false;
          nativeLibc = false;
          cc = bootstrapTools;
          inherit (bootstrapTools) isGNU;
          libc = bootstrapTools.glibc;
          binutils = bootstrapTools;
          coreutils = bootstrapTools;
          name = "bootstrap-cc-wrapper-stage0";
          stdenv = stage0Pkgs.stdenv;
        };
      };
    });
  };

  # This is the first package set and real stdenv using only the bootstrap tools
  # for building.
  # This stage is used for building the final glibc and linuxHeaders.
  stage1Pkgs = allPackages {
    inherit system platform;
    bootStdenv = import ../generic (commonStdenvOptions // commonBootstrapOptions // {
      name = "stdenv-linux-boot-stage1";
      cc = stage0Pkgs.gcc;
      extraBuildInputs = [ stage0Pkgs.patchelf ];

      extraAttrs = {
        # Having the proper 'platform' in all the stdenvs allows getting proper
        # linuxHeaders for example.
        inherit platform;

        # stdenv.glibc is used by GCC build to figure out the system-level
        # /usr/include directory.
        glibc = bootstrapTools.glibc;
      };

      overrides = pkgs: (lib.mapAttrs (n: _: throw "Tried to access ${n}") pkgs) // {
        inherit (pkgs) stdenv glibc linuxHeaders linuxHeaders_3_18;

        gcc = lib.makeOverridable (import ../../build-support/cc-wrapper) {
          nativeTools = false;
          nativeLibc = false;
          cc = bootstrapTools;
          isGNU = true; # Using glibc
          libc = stage1Pkgs.glibc;
          binutils = bootstrapTools;
          coreutils = bootstrapTools;
          name = "bootstrap-cc-wrapper-stage1";
          stdenv = stage0Pkgs.stdenv;
        };

        # These are only needed to evaluate
        inherit (stage0Pkgs) fetchurl patchelf;
        bison = null;
      };
    });
  };

  # This is the second package set using the final glibc and bootstrap tools.
  # This stage is used for building the final gcc.
  # Propagates stage1 glibc and linuxHeaders.
  stage2Pkgs = allPackages rec {
    inherit system platform;
    bootStdenv = import ../generic (commonStdenvOptions // commonBootstrapOptions // {
      name = "stdenv-linux-boot-stage2";
      cc = stage1Pkgs.gcc;
      extraBuildInputs = [ stage0Pkgs.patchelf ];

      extraAttrs = {
        # Having the proper 'platform' in all the stdenvs allows getting proper
        # linuxHeaders for example.
        inherit platform;

        # stdenv.glibc is used by GCC build to figure out the system-level
        # /usr/include directory.
        glibc = stage1Pkgs.glibc;
      };

      overrides = pkgs: (lib.mapAttrs (n: _: throw "Tried to access ${n}") pkgs) // {
        inherit (stage1Pkgs) glibc linuxHeaders linuxHeaders_3_18;
        inherit (pkgs) stdenv m4 which gettext;
        bzip2 = pkgs.bzip2.override { stdenv = pkgs.makeStaticLibraries pkgs.stdenv; };
        gmp = pkgs.gmp.override { stdenv = pkgs.makeStaticLibraries pkgs.stdenv; };
        isl = pkgs.isl.override { stdenv = pkgs.makeStaticLibraries pkgs.stdenv; };
        libelf = pkgs.libelf.override { };
        libmpc = pkgs.libmpc.override { stdenv = pkgs.makeStaticLibraries pkgs.stdenv; };
        mpfr = pkgs.mpfr.override { stdenv = pkgs.makeStaticLibraries pkgs.stdenv; };
        xz = pkgs.xz.override { stdenv = pkgs.makeStaticLibraries pkgs.stdenv; };
        zlib = pkgs.zlib.override { static = true; shared = false; };

        gcc = lib.makeOverridable (import ../../build-support/cc-wrapper) {
          nativeTools = false;
          nativeLibc = false;
          cc = pkgs.gcc.cc.override { shouldBootstrap = true; };
          isGNU = true; # Using glibc
          libc = stage1Pkgs.glibc;
          binutils = bootstrapTools;
          coreutils = bootstrapTools;
          name = "bootstrap-cc-wrapper-stage2";
          stdenv = stage0Pkgs.stdenv;
        };

        # These are only needed to evaluate
        inherit (stage0Pkgs) fetchurl patchelf;
        coreutils = bootstrapTools;
        binutils = bootstrapTools;
        perl = null;
        texinfo = null;
      };
    });
  };


  # This is the third package set using the final gcc, glibc and bootstrap tools.
  # This stage is used for building the final versions of all stdenv utilities.
  stage3Pkgs = allPackages rec {
    inherit system platform;
    bootStdenv = import ../generic (commonStdenvOptions // commonBootstrapOptions // {
      name = "stdenv-linux-boot-stage3";
      cc = stage2Pkgs.gcc;
      extraBuildInputs = [ stage0Pkgs.patchelf ];

      extraAttrs = {
        # Having the proper 'platform' in all the stdenvs allows getting proper
        # linuxHeaders for example.
        inherit platform;

        # stdenv.glibc is used by GCC build to figure out the system-level
        # /usr/include directory.
        glibc = stage1Pkgs.glibc;
      };

      overrides = pkgs: (lib.mapAttrs (n: _: throw "Tried to access ${n}") pkgs) // {
        pkgs = stage3Pkgs;
        inherit (stage1Pkgs) glibc linuxHeaders linuxHeaders_3_18;
        inherit (pkgs) stdenv xz zlib attr acl gmp coreutils binutils gpm
          ncurses readline bash libnghttp2 cryptodevHeaders openssl_1_0_2
          openssl c-ares curl libsigsegv pcre findutils diffutils gnused gnugrep
          gawk gnutar gzip bzip2 gnumake patch pkgconf pkgconfig patchelf;

        gcc = lib.makeOverridable (import ../../build-support/cc-wrapper) {
          nativeTools = false;
          nativeLibc = false;
          cc = stage2Pkgs.gcc.cc;
          isGNU = true; # Using glibc
          libc = stage1Pkgs.glibc;
          binutils = stage3Pkgs.binutils;
          coreutils = stage3Pkgs.coreutils;
          name = "cc-wrapper";
          stdenv = stage3Pkgs.stdenv;
          shell = stage3Pkgs.bash + "/bin/bash";
        };

        # Do not export these packages to the final stdenv
        inherit (stage0Pkgs) fetchurl;
        libiconv = null;
        inherit (pkgs) gettext perl522 perl m4 bison autoconf automake flex perlPackages
          libtool buildPerlPackage help2man makeWrapper autoreconfHook texinfo;
      };
    });
  };

  # Construct the final stdenv.  It uses the Glibc and GCC, and adds
  # in a new binutils that doesn't depend on bootstrap-tools, as well
  # as dynamically linked versions of all other tools.
  stdenvLinux = import ../generic (commonStdenvOptions // rec {
    name = "stdenv-final";

    # We want common applications in the path like gcc, mv, cp, tar, xz ...
    initialPath = lib.attrValues ((import ../common-path.nix) { pkgs = stage3Pkgs; });

    # We need patchelf to be a buildInput since it has to install a setup-hook.
    # We need pkgconfig to be a buildInput as it has aclocal files needed to
    # generate PKG_CHECK_MODULES.
    extraBuildInputs = with stage3Pkgs; [ patchelf pkgconfig ];

    cc = stage3Pkgs.gcc;

    shell = stage3Pkgs.gcc.shell;

    extraArgs = {
      stdenvDepTest = stage3Pkgs.stdenv.mkDerivation {
        name = "stdenv-dep-test";
        src = cc;
        installPhase = ''
          mkdir -p $out
        '' + lib.flip lib.concatMapStrings extraAttrs.bootstrappedPackages' (n: ''
          [ -h "$out/$(basename "${n}")" ] || ln -s "${n}" "$out"
        '');
        allowedRequisites = extraAttrs.bootstrappedPackages';
      };
    };

    extraAttrs = rec {
      inherit (stage1Pkgs) glibc;
      inherit platform;
      shellPackage = stage3Pkgs.gcc.shell;
      bootstrappedPackages' = lib.attrValues (overrides {}) ++ [ cc.cc ];
      bootstrappedPackages = [ stdenvLinux ] ++ bootstrappedPackages';
    };

    overrides = pkgs: {
      inherit (stage1Pkgs) glibc linuxHeaders linuxHeaders_3_18;
      inherit (stage3Pkgs) gcc xz zlib attr acl gmp coreutils binutils gpm
        ncurses readline bash libnghttp2 cryptodevHeaders openssl_1_0_2
        openssl c-ares curl libsigsegv pcre findutils diffutils gnused gnugrep
        gawk gnutar gzip bzip2 gnumake patch pkgconf pkgconfig patchelf;
    };
  });


  testBootstrapTools = let
    defaultPkgs = allPackages { inherit system platform; };
    bootstrapTools = bootstrapToolsTest;
  in derivation {
    name = "test-bootstrap-tools";
    inherit system;
    builder = bootstrapFiles.busybox;
    args = [ "ash" "-e" "-c" "eval \"$buildCommand\"" ];

    buildCommand = ''
      export PATH=${bootstrapTools}/bin

      ls -l
      mkdir $out
      mkdir $out/bin
      sed --version
      find --version
      diff --version
      patch --version
      make --version
      awk --version
      grep --version
      gcc --version
      curl --version
      pkgconfig --version

      ldlinux=$(echo ${bootstrapTools}/lib/ld-linux*.so.?)
      export CPP="cpp -idirafter ${bootstrapTools}/include-glibc -B${bootstrapTools}"
      export CC="gcc -idirafter ${bootstrapTools}/include-glibc -B${bootstrapTools} -Wl,-dynamic-linker,$ldlinux -Wl,-rpath,${bootstrapTools}/lib"
      export CXX="g++ -idirafter ${bootstrapTools}/include-glibc -B${bootstrapTools} -Wl,-dynamic-linker,$ldlinux -Wl,-rpath,${bootstrapTools}/lib"

      echo '#include <stdio.h>' >> foo.c
      echo '#include <limits.h>' >> foo.c
      echo 'int main() { printf("Hello World\\n"); return 0; }' >> foo.c
      $CC -o $out/bin/foo foo.c
      $out/bin/foo

      echo '#include <iostream>' >> bar.cc
      echo 'int main() { std::cout << "Hello World\\n"; }' >> bar.cc
      $CXX -v -o $out/bin/bar bar.cc
      $out/bin/bar

      tar xvf ${defaultPkgs.hello.src}
      cd hello-*
      ./configure --prefix=$out
      make
      make install
    '';
  };
}
