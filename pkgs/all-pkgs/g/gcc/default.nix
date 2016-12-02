{ stdenv
, bison
, binutils
, fetchTritonPatch
, fetchurl
, flex
, gettext
, gnum4
, perl

, gmp
, isl
, libunwind
, mpc
, mpfr
, zlib

, channel
# This is the platform the binutils can generate binaries for
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
  name = "${optionalString bootstrap "bootstrap-"}gcc-${version}";

  src = fetchurl {
    url = "mirror://gnu/gcc/gcc-${version}/gcc-${version}.tar.xz";
    inherit sha256;
  };

  nativeBuildInputs = [
    binutils
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
    # Don't look in fhs paths at runtime
    grep -r '"/\(usr\|lib\|lib64\)/' gcc/config \
      | awk -F: '{print $1}' | sort | uniq \
      | xargs -n 1 -P $NIX_BUILD_CORES sed -i 's,"/\(usr\|lib\|lib64\)/,"/no-such-path/,g'

    # Don't store configure flags in resulting excutables
    grep -q 'TOPLEVEL_CONFIGURE_ARGUMENTS=' Makefile.in
    sed -i '/TOPLEVEL_CONFIGURE_ARGUMENTS=/d' Makefile.in
  '' + optionalString bootstrap ''
    # We need to make sure the sources for libraries exist in the root directory
    # During a bootstrap build where we don't have the libraries available
    # ahead of time.
    unpackFile ${gmp.src}
    mv gmp-* gmp
    unpackFile ${isl.src}
    mv isl-* isl
    unpackFile ${mpc.src}
    mv mpc-* mpc
    unpackFile ${mpfr.src}
    mv mpfr-* mpfr
  '' + optionalString (!bootstrap) ''
    # We don't want to use the included zlib
    rm -r zlib
  '';

  preConfigure = ''
    # GCC interprets empty paths as ".", which we don't want.
    if test -z "$CPATH"; then
      unset CPATH
    fi
    if test -z "$LIBRARY_PATH"; then
      unset LIBRARY_PATH
    fi
  '';

  configureFlags = [
    # Always treat bootstrapping as cross compiling
    (if bootstrap then "--target=${stdenv.cc.platformTuples."${outputSystem}-boot"}" else null)
    "--enable-static"
    "--${if !bootstrap then "enable" else "disable"}-shared"
    "--with-pic"
    "--with-sysroot=/no-such-path"
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
    LIBC_INCLUDE="$(cat "$NIX_CC/nix-support/libc-include")"

    export CFLAGS="$(cat $NIX_CC/nix-support/libc-cflags)"
    for flag in $(cat $NIX_CC/nix-support/libc-ldflags-before) $(cat $NIX_CC/nix-support/libc-ldflags); do
      export LDFLAGS="$LDFLAGS -Wl,$flag"
    done
  '' + optionalString bootstrap ''
    # When bootstrapping we want a static compiler
    export LDFLAGS="$LDFLAGS -static";
  '' + ''
    # Reduces the size of intermediate binaries
    export CFLAGS="$CFLAGS -O2"

    buildFlagsArray+=(
      NATIVE_SYSTEM_HEADER_DIR="$LIBC_INCLUDE"
      SYSTEM_HEADER_DIR="$LIBC_INCLUDE"
      CFLAGS_FOR_BUILD="$CFLAGS"
      CXXFLAGS_FOR_BUILD="$CFLAGS"
      CFLAGS_FOR_TARGET="$CFLAGS"
      CXXFLAGS_FOR_TARGET="$CFLAGS"
      FLAGS_FOR_TARGET="$CFLAGS"
      LDFLAGS_FOR_BUILD="$LDFLAGS"
      LDFLAGS_FOR_TARGET="$LDFLAGS"
    )
  '' + optionalString bootstrap ''
    buildFlagsArray+=(
      "BOOT_CFLAGS=$CFLAGS"
      "BOOT_LDFLAGS=$LDFLAGS"
    )
  '' + ''
    exit_err() {
      local status="$?"
      echo "############# DEBUGGING #############"
      export NIX_DEBUG=1
      export buildParallel=
      local actualFlags
      commonMakeFlags 'build'
      printFlags 'build'
      make "''${actualFlags[@]}" || true
      while read name; do
        echo "############# $name #############"
        cat "$name"
        echo ""
      done < <(find host* -name config.log)
      exit "$status"
    }
    trap exit_err ERR
  '';

  buildFlags = optionals (!bootstrap) [
    "LIMITS_H_TEST=true"
    "bootstrap-lean" # Removes files as they are no longer needed
  ] ++ optionals bootstrap [
    "LIMITS_H_TEST=false"
  ];

  # Installed tools are not used by the compiler and can be safely removed
  # Usually these contain references to the compiler used to build stage0
  postInstall = ''
    find "$out" -name install-tools -prune -exec rm -r {} \;
  '';

  # Deduplicate binaries
  preFixup = ''
    pushd "$out"/bin >/dev/null
    prevHash=""
    prevFile=""
    OLDIFS="$IFS"
    IFS=$'\n'
    for line in $(find . -type f -exec cksum {} \; | sort); do
      hash="$(echo "$line" | awk '{print $1 " " $2}')"
      file="$(echo "$line" | awk '{print $3}')"
      if [ "$prevHash" = "$hash" ]; then
        if cmp -s "$file" "$prevFile"; then
          rm "$file"
          ln -sv "$prevFile" "$file"
        fi
      else
        prevHash="$hash"
        prevFile="$file"
      fi
    done
    IFS="$OLDIFS"
    popd >/dev/null
  '';

  ccFixFlags = !bootstrap;
  buildDirCheck = !bootstrap;
  disableStatic = false;

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
