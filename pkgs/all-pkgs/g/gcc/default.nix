{ stdenv
, autotools
, binutils
, bison
, cc
, coreutils
, diffutils
, fetchTritonPatch
, fetchurl
, flex
, gettext
, gnum4
, gnumake
, gnupatch
, gnutar
, gzip
, perl
, xz

, gmp
, isl
, libunwind
, mpc
, mpfr
, zlib

, channel
# This is the platform the gcc can generate binaries for
, outputSystem ? stdenv.targetSystem
, bootstrap ? false
}:

# WHEN UPDATING THE ARGUMENT LIST ALSO UPDATE STDENV.

let
  sources = import ./sources.nix {
    inherit fetchTritonPatch;
  };
  inherit (sources."${channel}")
    patches
    sha256
    version;

  inherit (stdenv.lib)
    optionals
    optionalString;
in
stdenv.mkDerivation (rec {
  name = "gcc-${version}";

  src = fetchurl {
    url = "mirror://gnu/gcc/gcc-${version}/gcc-${version}.tar.xz";
    inherit sha256;
  };

  nativeBuildInputs = [
    autotools
    binutils
    cc
    coreutils
    diffutils
    gnumake
    gnupatch
    gnutar
    gzip
    xz
  ] ++ optionals (!bootstrap) [
    bison
    flex
    gettext
    gnum4
    perl
  ];

  buildInputs = optionals (!bootstrap) [
    gmp
    isl
    mpc
    mpfr
    zlib
  ];

  inherit patches;

  postPatch = ''
    # Fix error msg that makes the build appear to contain impure paths
    grep -q 'unary/binary/ternary' "$srcRoot"/gcc/tree-vect-stmts.c
    sed -i 's,unary/binary/ternary,unary / binary / ternary,' "$srcRoot"/gcc/tree-vect-stmts.c

    # Don't look in fhs paths at runtime
    grep -r '"/\(usr\|lib\|lib64\|libx32\|system\)/' "$srcRoot"/gcc/config \
      | awk -F: '{print $1}' | sort | uniq \
      | xargs -n 1 -P $NIX_BUILD_CORES sed -i 's,"/\(usr\|lib\|lib64\|libx32\|system\)/,"/no-such-path/,g'

    # Make sure we don't have unwanted /usr paths
    grep -q '"/usr/lib/"' "$srcRoot"/gcc/gcc.c
    sed -i 's,"/usr/lib/","/no-such-path/lib/",' "$srcRoot"/gcc/gcc.c

    # Don't store configure flags in resulting excutables
    grep -q 'TOPLEVEL_CONFIGURE_ARGUMENTS=' "$srcRoot"/Makefile.in
    sed -i '/TOPLEVEL_CONFIGURE_ARGUMENTS=/d' "$srcRoot"/Makefile.in

    # Fix calls to sh instead of SHELL
    grep -q '^'$'\t'"sh " "$srcRoot"/libgcc/Makefile.in
    sed -i 's,^\tsh ,\t$(SHELL) ,' "$srcRoot"/libgcc/Makefile.in
  '' + optionalString bootstrap ''
    # We need to make sure the sources for libraries exist in the root directory
    # During a bootstrap build where we don't have the libraries available
    # ahead of time.
    mkdir -p "$NIX_BUILD_TOP"/tmp
    pushd "$NIX_BUILD_TOP" >/dev/null

    applyFile 'unpack' '${gmp.src}'
    mv gmp-* "$srcRoot"/gmp

    applyFile 'unpack' '${isl.src}'
    mv isl-* "$srcRoot"/isl

    applyFile 'unpack' '${mpc.src}'
    mv mpc-* "$srcRoot"/mpc

    applyFile 'unpack' '${mpfr.src}'
    mv mpfr-* "$srcRoot"/mpfr

    popd >/dev/null
  '' + optionalString (!bootstrap) ''
    # We don't want to use the included zlib
    rm -r "$srcRoot"/zlib
  '';

  # GCC interprets empty paths as ".", which we don't want.
  preConfigure = ''
    unset CPATH
    unset LIBRARY_PATH
  '';

  configureFlags = [
    # Always treat bootstrapping as cross compiling
    (if bootstrap then "--target=${cc.platformTuples."${outputSystem}-boot"}" else null)
    "--enable-static"
    "--${if !bootstrap then "enable" else "disable"}-shared"
    "--with-pic"
    "--with-local-prefix=/no-such-path"
    "--${if !bootstrap then "with" else "without"}-headers"
    "--${if !bootstrap then "enable" else "disable"}-libquadmath"
    "--${if !bootstrap then "enable" else "disable"}-libquadmath-support"
    "--${if !bootstrap then "enable" else "disable"}-libatomic"
    "--disable-libgcj"
    "--disable-libada"
    "--${if !bootstrap then "enable" else "disable"}-libcc1"
    "--${if !bootstrap then "enable" else "disable"}-libgomp"
    "--${if !bootstrap then "enable" else "disable"}-libcilkrts"
    "--${if !bootstrap then "enable" else "disable"}-libssp"
    "--${if !bootstrap then "enable" else "disable"}-libstdcxx"
    "--disable-liboffloadmic"
    "--${if !bootstrap then "enable" else "disable"}-libitm"
    "--${if !bootstrap then "enable" else "disable"}-libsanitizer"
    "--${if !bootstrap then "enable" else "disable"}-libvtv"
    "--${if !bootstrap then "enable" else "disable"}-libmpx"
    "--${if !bootstrap then "enable" else "disable"}-bootstrap"
    "--disable-werror"
    "--with-long-double-128"
    (if bootstrap then null else "--with-mpc")
    (if bootstrap then null else "--with-mpfr")
    (if bootstrap then null else "--with-gmp")
    (if bootstrap then null else "--with-isl")
    (if bootstrap then null else "--enable-lto")  # We should be able to enable this
    # This is really a hack to enable -Dinhibit_libc and we aren't actually using newlib in the bootstrap
    "--${if bootstrap then "with" else "without"}-newlib"
    "--with-glibc-version=${if bootstrap then "2.11" else "${stdenv.libc.version}"}"
    "--${if !bootstrap then "enable" else "disable"}-nls"
    "--${if !bootstrap then "with" else "without"}-system-zlib"
    "--without-tcl"
    "--without-tk"
    "--${if !bootstrap then "enable" else "disable"}-threads"
    "--disable-symbols"
    "--${if !bootstrap then "with" else "without"}-system-libunwind"
    "--${if !bootstrap then "with" else "without"}-zlib"
    "--disable-multilib"
    "--disable-checking"
    "--disable-coverage"
    "--disable-multiarch"
    "--enable-tls"
    "--enable-languages=c,c++"
  ];

  preBuild = ''
    eval `CC_WRAPPER_PRINT_CONFIG=1 cc-wrapper`

    # Reduces the size of intermediate binaries
    export CFLAGS="''${CFLAGS-} -O2"

    buildFlagsArray+=(
      NATIVE_SYSTEM_HEADER_DIR="$TARGET_LIBC_INCLUDE"
      SYSTEM_HEADER_DIR="/no-such-path"
      CFLAGS_FOR_BUILD=""
      CXXFLAGS_FOR_BUILD=""
      CFLAGS_FOR_TARGET=""
      CXXFLAGS_FOR_TARGET=""
      FLAGS_FOR_TARGET=""
      LDFLAGS_FOR_BUILD=""
      LDFLAGS_FOR_TARGET=""
    )
  '' + optionalString bootstrap ''
    buildFlagsArray+=(
      "BOOT_CFLAGS="
      "BOOT_LDFLAGS="
    )
  '';
  /*+ ''
    exit_err() {
      local status="$?"
      echo "############# DEBUGGING #############"
      export NIX_DEBUG=1
      export CC_WRAPPER_LOG_LEVEL=info
      export buildParallel=
      makeBuildAction || true
      while read name; do
        echo "############# $name #############"
        cat "$name"
        echo ""
      done < <(find "$buildRoot" -name config.log)
      exit "$status"
    }
    trap exit_err ERR EXIT
  '';*/

  buildFlags = optionals (!bootstrap) [
    "LIMITS_H_TEST=true"
    "bootstrap-lean" # Removes files as they are no longer needed
  ] ++ optionals bootstrap [
    "LIMITS_H_TEST=false"
  ];

  # Installed tools are not used by the compiler and can be safely removed
  # Usually these contain references to the compiler used to build stage0
  # Also remove versioned binaries
  postInstall = ''
    for output in $outputs; do
      find "''${!output}" -name install-tools -prune -exec rm -r {} \;
    done
    find "$bin"/bin -name \*${version}\* -delete
  '';

  # Make sure we retain no references to the FHS hierarchy of paths
  preFixupCheck = ''
    for output in bin dev lib; do
      if grep -rao '[a-zA-Z0-9_/.%-]*/\(bin\|include\|lib\|libexec\)' "''${!output}" | grep -v "^[^:]*:[ ]*\\([^/]\\|/no-such-path\\|$NIX_STORE\\|$NIX_BUILD_TOP\\)"; then
        echo "Found FHS paths. We definitely don't want this";
        exit 1
      fi
    done
  '';

  disableStatic = false;

  outputs = autotools.commonOutputs;

  passthru = {
    langAda = false;
    langFortran = false;
    langGo = false;
    langJava = false;
    langVhdl = false;
    isGNU = true;

    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "33C2 35A3 4C46 AA3F FB29  3709 A328 C3A2 C3C4 5C06";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
} // (if bootstrap then { } else {
  # We should only ever reference ourselves or a real libc
  # It's fine if the bootstrap compiler has outside dependencies
  allowedReferences = [
    "out"
    stdenv.libc
  ];
}))
