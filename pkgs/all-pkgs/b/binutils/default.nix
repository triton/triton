{ stdenv
, lib
, autotools
, bison
, cc
, coreutils
, diffutils
, fetchTritonPatch
, fetchurl
, flex
, gnugrep
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

  target = cc.platformTuples."${outputSystem}-boot";

  version = "2.30";
in
stdenv.mkDerivation rec {
  name = "binutils-${version}";

  src = fetchurl {
    url = "mirror://gnu/binutils/binutils-${version}.tar.xz";
    hashOutput = false;
    sha256 = "6e46b8aeae2f727a36f0bd9505e405768a72218f1796f0d09757d45209871ae6";
  };

  # We don't need to provide any packages to the bootstrap
  nativeBuildInputs = [
    autotools
    #bison
    cc
    coreutils
    diffutils
    #flex
    gnugrep
    #gnum4
    gnumake
    gnupatch
    gnutar
    xz
  ];

  # We don't need to provide any packages to the bootstrap
  buildInputs = optionals (!bootstrap) [
    gmp
    isl
    mpc
    mpfr
    zlib
  ];

  # We can't apply the rollup during bootstrap since this would
  # require us to have a `makeinfo` binary
  patches = optionals (!bootstrap) [
    (fetchTritonPatch {
      rev = "2de0054fdd5a211c7801433dda343a312ab8f00b";
      file = "b/binutils/0000-upstream-fixes.patch";
      sha256 = "cb96aed03b9137c70eae895f6d781501b9df1320dc7c755745e3316e1ffa7566";
    })
  ] ++ [
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

    # Don't build tests
    sed -i '/SUBDIRS/s, testsuite,,g' "$srcRoot"/gold/Makefile.in
  '';

  configureFlags = [
    "--disable-werror"
    "--enable-gold=default"
    "--enable-ld"
    "--${if !bootstrap then "enable" else "disable"}-shared"
    "--enable-static"
    "--${if !bootstrap then "enable" else "disable"}-nls"
    "--${if !bootstrap then "enable" else "disable"}-plugins"
    "--enable-deterministic-archives"
    "--${if !bootstrap then "with" else "without"}-system-zlib"
  ] ++ optionals bootstrap [
    "--target=${target}"  # Always treat bootstrapping like cross compiling
  ] ++ optionals (elem outputSystem bit64) [
    "--enable-64-bit-archive"
  ];

  preFixup = optionalString bootstrap ''
    rm -r "$bin"/'${target}'
  '';

  # Make sure we retain no references to the FHS hierarchy of paths
  preFixupCheck = ''
    set -x
    for output in bin dev lib; do
      if grep -rao '[a-zA-Z0-9_-/]*/\(bin\|include\|lib\|libexec\)' "''${!output}" | grep -v ':\(/no-such-path\|/nix/store\)'; then
        echo "Found FHS paths in binutils. We definitely don't want this";
        exit 1
      fi
    done
    set +x
  '';

  disableStatic = false;

  passthru = {
    inherit version;
  };

  outputs = autotools.commonOutputs;

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
