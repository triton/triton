# This file constructs the standard build environment for the
# Linux platform.  It's completely pure; that is, it relies on no
# external (non-Nix) tools, such as /usr/bin/gcc, and it contains a C
# compiler and linker that do not search in default locations,
# ensuring purity of components produced by it.

{ allPackages
, lib
, targetSystem
, hostSystem
, config
}:

# We haven't fleshed out cross compiling yet
assert targetSystem == hostSystem;

let

  bootstrapFiles = import ./bootstrap.nix { inherit lib hostSystem; };

  commonStdenvOptions = {
    inherit targetSystem hostSystem config;
    preHook = ''
      export NIX_ENFORCE_PURITY=1
    '';
  };

  bootstrapTools = derivation {
    name = "bootstrap-tools";

    builder = bootstrapFiles.busybox;

    args = [ "ash" "-e" ./unpack-bootstrap-tools.sh ];

    tarball = bootstrapFiles.bootstrapTools;

    inherit (bootstrapFiles)
      langC
      langCC
      isGNU;

    outputs = [ "out" "glibc" ];

    system = hostSystem;
  };

  bootstrapShell = "${bootstrapTools}/bin/bash";

  commonBootstrapOptions = {
    shell = bootstrapShell;
    initialPath = [ bootstrapTools ];
    extraBuildInputs = [ ];

    # We cant patch shebangs or we will retain references to the bootstrap
    preHook = ''
      export dontPatchShebangs=1
    '';

  };

  # This is not a real set of packages or stdenv.
  # This is just enough for us to use stdenv.mkDerivation to build our
  # first cc-wrapper and fetchurlBoot.
  # This does not provide any actual packages.
  stage0Pkgs = allPackages {
    inherit targetSystem hostSystem config;
    stdenv = import ../generic { inherit lib; } (commonStdenvOptions // commonBootstrapOptions // {
      name = "stdenv-linux-boot-stage0";

      cc = null;

      overrides = pkgs: (lib.mapAttrs (n: _: throw "stage0Pkgs is missing package definition for `${n}`") pkgs) // rec {
        inherit (pkgs) stdenv;

        fetchurl = import ../../build-support/fetchurl {
          stdenv = stage0Pkgs.stdenv;
          curl = bootstrapTools;
        };

        fetchzip = import ../../build-support/fetchzip {
          lib = stage0Pkgs.stdenv.lib;
          unzip = bootstrapTools;
          inherit fetchurl;
        };

        fetchFromGitHub = a: pkgs.fetchFromGitHub (a // { fetchzip' = fetchzip; });

        fetchTritonPatch = args: pkgs.fetchTritonPatch (args // { fetchurl' = fetchurl; });

        patchelf = stage0Pkgs.stdenv.mkDerivation {
          name = "patchelf-boot";
          src = bootstrapTools;
          installPhase = ''
            mkdir -p $out/bin
            ln -s $bootstrapTools/bin/patchelf $out/bin
          '';
          setupHook = pkgs.patchelf.setupHook;
          dontAbsoluteLibtool = true; # Depends on cc not being null
        };

        gcc = lib.makeOverridable (import ../../build-support/cc-wrapper) {
          nativeTools = false;
          nativeLibc = false;
          cc = bootstrapTools;
          inherit (bootstrapTools) isGNU;
          libc = bootstrapTools.glibc;
          binutils = bootstrapTools;
          coreutils = bootstrapTools;
          gnugrep = bootstrapTools;
          name = "bootstrap-cc-wrapper-stage0";
          stdenv = stage0Pkgs.stdenv;
        };
      };
    });
  };

  # This is the first package set and real stdenv using only the bootstrap tools
  # for building.
  # This stage is used for building the final glibc and linux-headers.
  stage1Pkgs = allPackages {
    inherit targetSystem hostSystem config;
    stdenv = import ../generic { inherit lib; } (commonStdenvOptions // commonBootstrapOptions // {
      name = "stdenv-linux-boot-stage1";
      cc = stage0Pkgs.gcc;
      extraBuildInputs = [ stage0Pkgs.patchelf ];

      extraAttrs = {
        # stdenv.libc is used by GCC build to figure out the system-level
        # /usr/include directory.
        libc = bootstrapTools.glibc;
      };

      overrides = pkgs: (lib.mapAttrs (n: _: throw "stage1Pkgs is missing package definition for `${n}`") pkgs) // {
        inherit (pkgs) stdenv glibc linux-headers;

        gcc = lib.makeOverridable (import ../../build-support/cc-wrapper) {
          nativeTools = false;
          nativeLibc = false;
          cc = bootstrapTools;
          isGNU = true; # Using glibc
          libc = stage1Pkgs.glibc;
          binutils = bootstrapTools;
          coreutils = bootstrapTools;
          gnugrep = bootstrapTools;
          name = "bootstrap-cc-wrapper-stage1";
          stdenv = stage0Pkgs.stdenv;
        };

        # These are only needed to evaluate
        inherit (stage0Pkgs) fetchurl fetchzip fetchFromGitHub fetchTritonPatch patchelf;
        bison = null;
      };
    });
  };

  # This is the second package set using the final glibc and bootstrap tools.
  # This stage is used for building the final gcc.
  # Propagates stage1 glibc and linux-headers.
  stage2Pkgs = allPackages rec {
    inherit targetSystem hostSystem config;
    stdenv = import ../generic { inherit lib; } (commonStdenvOptions // commonBootstrapOptions // {
      name = "stdenv-linux-boot-stage2";
      cc = stage1Pkgs.gcc;
      extraBuildInputs = [ stage0Pkgs.patchelf ];

      extraAttrs = {
        # stdenv.libc is used by GCC build to figure out the system-level
        # /usr/include directory.
        libc = stage1Pkgs.glibc;
      };

      overrides = pkgs: (lib.mapAttrs (n: _: throw "stage2Pkgs is missing package definition for `${n}`") pkgs) // {
        inherit (stage1Pkgs) glibc linux-headers;
        inherit (pkgs) stdenv gnum4 m4 which gettext elfutils;
        bzip2 = pkgs.bzip2.override { static = true; shared = false; };
        libelf = pkgs.libelf.override { static = true; shared = false; };
        gmp = pkgs.gmp.override { stdenv = pkgs.makeStaticLibraries pkgs.stdenv; };
        isl = pkgs.isl.override { stdenv = pkgs.makeStaticLibraries pkgs.stdenv; };
        libmpc = pkgs.libmpc.override { stdenv = pkgs.makeStaticLibraries pkgs.stdenv; };
        mpfr = pkgs.mpfr.override { stdenv = pkgs.makeStaticLibraries pkgs.stdenv; };
        xz = pkgs.xz.override { stdenv = pkgs.makeStaticLibraries pkgs.stdenv; };
        zlib = pkgs.zlib.override { static = true; shared = false; };

        gcc = lib.makeOverridable (import ../../build-support/cc-wrapper) {
          nativeTools = false;
          nativeLibc = false;
          cc = pkgs.gcc.cc.override {
            shouldBootstrap = true;
            libPathExcludes = [ "${bootstrapTools}/lib"];
          };
          isGNU = true; # Using glibc
          libc = stage1Pkgs.glibc;
          binutils = bootstrapTools;
          coreutils = bootstrapTools;
          gnugrep = bootstrapTools;
          name = "bootstrap-cc-wrapper-stage2";
          stdenv = stage0Pkgs.stdenv;
        };

        # These are only needed to evaluate
        inherit (stage0Pkgs) fetchurl fetchzip fetchFromGitHub fetchTritonPatch patchelf;
        coreutils = bootstrapTools;
        binutils = bootstrapTools;
        gnugrep = bootstrapTools;
        perl = null;
        texinfo = null;
      };
    });
  };


  # This is the third package set using the final gcc, glibc and bootstrap tools.
  # This stage is used for building the final versions of all stdenv utilities.
  stage3Pkgs = allPackages rec {
    inherit targetSystem hostSystem config;
    stdenv = import ../generic { inherit lib; } (commonStdenvOptions // commonBootstrapOptions // {
      name = "stdenv-linux-boot-stage3";
      cc = stage2Pkgs.gcc;
      extraBuildInputs = [ stage0Pkgs.patchelf ];

      extraAttrs = {
        # stdenv.libc is used by GCC build to figure out the system-level
        # /usr/include directory.
        libc = stage1Pkgs.glibc;
      };

      overrides = pkgs: (lib.mapAttrs (n: _: throw "stage3Pkgs is missing package definition for `${n}`") pkgs) // {
        pkgs = stage3Pkgs;
        inherit (stage1Pkgs) glibc linux-headers;
        inherit (stage2Pkgs) m4 gnum4 which gettext;
        inherit (pkgs) stdenv xz zlib attr acl gmp coreutils binutils
          gpm ncurses readline bash libnghttp2 cryptodevHeaders
          openssl c-ares curl libsigsegv pcre findutils diffutils gnused gnugrep
          gawk gnutar gzip bzip2 gnumake gnupatch pkgconf pkgconfig patchelf;

        gcc = lib.makeOverridable (import ../../build-support/cc-wrapper) {
          nativeTools = false;
          nativeLibc = false;
          cc = stage2Pkgs.gcc.cc;
          isGNU = true; # Using glibc
          libc = stage1Pkgs.glibc;
          binutils = stage3Pkgs.binutils;
          coreutils = stage3Pkgs.coreutils;
          gnugrep = stage3Pkgs.gnugrep;
          name = "cc-wrapper";
          stdenv = stage3Pkgs.stdenv;
          shell = stage3Pkgs.bash + "/bin/bash";
        };

        # Do not export these packages to the final stdenv
        inherit (stage0Pkgs) fetchurl fetchzip fetchFromGitHub fetchTritonPatch;
        libiconv = null;
        texinfo = pkgs.texinfo.override {
          interactive = false;
          doCheck = false;
        };
        inherit (pkgs) perl522 perl bison autoconf automake flex perlPackages
          libtool buildPerlPackage help2man makeWrapper autoreconfHook nghttp2;
        jansson = null;
      };
    });
  };

  # Construct the final stdenv.  It uses the Glibc and GCC, and adds
  # in a new binutils that doesn't depend on bootstrap-tools, as well
  # as dynamically linked versions of all other tools.
  stdenv = import ../generic { inherit lib; } (commonStdenvOptions // rec {
    name = "stdenv-final";

    # We want common applications in the path like gcc, mv, cp, tar, xz ...
    initialPath = lib.attrValues ((import ../generic/common-path.nix) { pkgs = stage3Pkgs; });

    # We need patchelf to be a buildInput since it has to install a setup-hook.
    # We need pkgconfig to be a buildInput as it has aclocal files needed to
    # generate PKG_CHECK_MODULES.
    extraBuildInputs = with stage3Pkgs; [ patchelf pkgconfig ];

    cc = stage3Pkgs.gcc;

    shell = stage3Pkgs.gcc.shell;

    extraArgs = rec {
      stdenvDeps = stage3Pkgs.stdenv.mkDerivation {
        name = "stdenv-deps";
        buildCommand = ''
          mkdir -p $out
        '' + lib.flip lib.concatMapStrings extraAttrs.bootstrappedPackages' (n: ''
          [ -h "$out/$(basename "${n}")" ] || ln -s "${n}" "$out"
        '');
      };
      stdenvDepTest = stage3Pkgs.stdenv.mkDerivation {
        name = "stdenv-dep-test";
        buildCommand = ''
          mkdir -p $out
          ln -s "${stdenvDeps}" $out
        '';
        allowedRequisites = extraAttrs.bootstrappedPackages' ++ [ stdenvDeps ];
      };
    };

    extraAttrs = rec {
      libc = stage1Pkgs.glibc;
      shellPackage = stage3Pkgs.gcc.shell;
      bootstrappedPackages' = lib.attrValues (overrides {}) ++ [ cc.cc cc ] ++ extraBuildInputs;
      bootstrappedPackages = [ stdenv ] ++ bootstrappedPackages';
    };

    overrides = pkgs: {
      inherit (stage1Pkgs) glibc linux-headers;
      inherit (stage2Pkgs) m4 gnum4 which gettext;
      inherit (stage3Pkgs) gcc xz zlib attr acl gmp coreutils binutils
        gpm ncurses readline bash libnghttp2 cryptodevHeaders
        openssl c-ares curl libsigsegv pcre findutils diffutils gnused gnugrep
        gawk gnutar gzip bzip2 gnumake gnupatch pkgconf pkgconfig patchelf;
    };
  });
in {
  inherit bootstrapTools stage0Pkgs stage1Pkgs stage2Pkgs stage3Pkgs stdenv;
}
