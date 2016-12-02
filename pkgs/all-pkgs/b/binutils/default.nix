{ stdenv
, lib
, autotools
, bison
, fetchTritonPatch
, fetchurl
, flex
, gnum4
, gnumake
, gnupatch
, gnutar
, xz

, gmp
, isl
, mpc
, mpfr
, zlib

# This is the platform the binutils can generate binaries for
, outputSystem ? stdenv.targetSystem
, bootstrap ? false
}:

assert bootstrap -> stdenv.targetSystem == stdenv.hostSystem;

let
  inherit (lib)
    elem
    head
    optional
    optionals
    optionalString;

  inherit (lib.platforms)
    bit64
    i686-linux
    x86_64-linux;

  version = "2.29.1";
in
stdenv.mkDerivation rec {
  name = "${if bootstrap then "bootstrap-" else ""}binutils-${version}";

  src = fetchurl {
    url = "mirror://gnu/binutils/binutils-${version}.tar.xz";
    hashOutput = false;
    sha256 = "e7010a46969f9d3e53b650a518663f98a5dde3c3ae21b7d71e5e6803bc36b577";
  };

  # We don't need to provide any packages to the bootstrap
  nativeBuildInputs = [
    autotools
    gnumake
    gnupatch
    gnutar
    xz
  ] ++ optionals (!bootstrap) [
    bison
    flex
    gnum4
  ];

  # We don't need to provide any packages to the bootstrap
  buildInputs = optionals (!bootstrap) [
    gmp
    isl
    mpc
    mpfr
    zlib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "d6105b421c56c0d4d641e067e31d1df85c32830d";
      file = "b/binutils/0000-upstream-fixes.patch";
      sha256 = "2daf618eee6de07d9b769bd3f5a29c73ed53e3044b100b137a015ec59a081e97";
    })
    (fetchTritonPatch {
      rev = "a03cde5368a0265105fe8be99ef193585334cb37";
      file = "b/binutils/0001-always-runpath.patch";
      sha256 = "8144e49930871f6b5c14ba9b4759ba56e873272b34782530df1d7061f77d8ea3";
    })
    (fetchTritonPatch {
      rev = "a03cde5368a0265105fe8be99ef193585334cb37";
      file = "b/binutils/0002-deterministic.patch";
      sha256 = "f215170d3d746ae8d4c3b9e1a56121b6ec2c9036810797a5cf6f2017d8313206";
    })
	];

  postPatch = ''
    # Remove any patch conflict files
    find "$srcRoot" -name \*.orig -type f -delete

    # Make sure that we are not missing any determinism flags
    if grep -r '& BFD_DETERMINISTIC_OUTPUT' "$srcRoot"; then
      echo "Found DETERMINISM flags" >&2
      exit 1
    fi
  '' + optionalString (!bootstrap) ''
    # We don't want to use the built in zlib
    rm -r "$srcRoot"/zlib
  '' + ''
    # Use symlinks instead of hard links to save space ("strip" in the
    # fixup phase strips each hard link separately).
    # Also disable documentation generation
    find "$srcRoot" -name Makefile.in -exec sed -i {} -e 's,ln ,ln -s ,g' -e 's,\(SUBDIRS.*\) doc,\1,g' \;

    # Fixup any FHS paths in the source tree
    find "$srcRoot" -name \*.c -or -name \*.h -or -name \*.cc | xargs sed \
      -e 's,/usr,/no-such-path,g' \
      -e 's,\(:\|"\)/\(lib\|bin\|libexec\|include\),\1/no-such-path/\2,g' \
      -i
  '';

  configureFlags = [
    "--disable-werror"
    "--enable-gold=default"
    "--enable-ld"
    "--${if !bootstrap then "enable" else "disable"}-shared"
    "--${if !bootstrap then "enable" else "disable"}-nls"
    "--${if !bootstrap then "enable" else "disable"}-plugins"
    "--enable-deterministic-archives"
    "--${if !bootstrap then "with" else "without"}-system-zlib"
  ] ++ optionals bootstrap [
    "--target=${stdenv.cc.platformTuples."${outputSystem}-boot"}"  # Always treat bootstrapping like cross compiling
  ] ++ optionals (elem stdenv.targetSystem bit64) [
    "--enable-64-bit-archive"
  ];

  preBuild = ''
    makeFlagsArray+=("tooldir=$out")
  '';

  preFixup = optionalString bootstrap ''
    find "$out" -not -name bin -and -not -name share -mindepth 1 -maxdepth 1 | xargs -r rm -r
  '';

  # Make sure we retain no references to the FHS hierarchy of paths
  preFixupCheck = ''
    if grep -rao '[a-zA-Z0-9_-/]*/\(bin\|include\|lib\|libexec\)' "$out" | grep -v ':\(/no-such-path\|/nix/store\)'; then
      echo "Found FHS paths in binutils. We definitely don't want this";
      exit 1
    fi
  '';

  ccFixFlags = !bootstrap;
  buildDirCheck = !bootstrap;
  disableStatic = false;

  passthru = {
    inherit version;
  };

  meta = with lib; {
    description = "Tools for manipulating binaries (linker, assembler, etc.)";
    homepage = http://www.gnu.org/software/binutils/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
