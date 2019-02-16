{ stdenv
, fetchTritonPatch
, fetchurl

, binutils
, gmp
, isl
, libc
, libmpc
, linux-headers
, mpfr
, zlib

, type ? "full"
}:

let
  inherit (stdenv.lib)
    boolEn
    boolWt
    optional
    optionals
    optionalAttrs
    optionalString
    stringLength;

  target =
    if type == "bootstrap" then
      "x86_64-tritonboot-linux-gnu"
    else
      "x86_64-pc-linux-gnu";

  nativeHeaders =
    if type == "bootstrap" then
      "/no-such-path/native-headers"
    else
      "${libc}/include";

  checking =
    if type == "bootstrap" then
      "yes"
    else
      "release";

  version = "8.2.0";
in
stdenv.mkDerivation (rec {
  name = "gcc-${version}";

  src = fetchurl {
    url = "mirror://gnu/gcc/${name}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "196c3c04ba2613f893283977e6011b2345d1cd1af9abeac58e916b1aab3e0080";
  };

  buildInputs = optionals (type != "bootstrap") [
    gmp
    isl
    libmpc
    mpfr
    zlib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "4d2c1a5a183beed4144231b286099ec6c8e4691b";
      file = "g/gcc/8.2.0/0001-libcpp-Enforce-purity-BT_TIMESTAMP.patch";
      sha256 = "fa813790569c7e1c1404924a2bb9913575fe4a1775945ed45ba717c7345a0e25";
    })
    (fetchTritonPatch {
      rev = "4d2c1a5a183beed4144231b286099ec6c8e4691b";
      file = "g/gcc/8.2.0/0002-c-ada-spec-Workaround-for-impurity-detection.patch";
      sha256 = "396ec3139791032833b5cf7c65d4fa8a897199bbca98a67073d2e667d24a9634";
    })
    (fetchTritonPatch {
      rev = "4d2c1a5a183beed4144231b286099ec6c8e4691b";
      file = "g/gcc/8.2.0/0003-gcc-Don-t-hardcode-startfile-locations.patch";
      sha256 = "82b818f5d8ceec63437a7d9614a54c6895d94778c5904efedffeee00052a2995";
    })
    (fetchTritonPatch {
      rev = "4d2c1a5a183beed4144231b286099ec6c8e4691b";
      file = "g/gcc/8.2.0/0004-cppdefault-Don-t-add-a-default-local_prefix-include.patch";
      sha256 = "ae6a5002b197f81b76a949dc808e450dd5ed3b5951979b6a5f9987f2a76ce71c";
    })
    (fetchTritonPatch {
      rev = "4d2c1a5a183beed4144231b286099ec6c8e4691b";
      file = "g/gcc/8.2.0/0005-2018-08-01-Richard-Biener-rguenther-suse.de.patch";
      sha256 = "549433094b3795f00ea5b40b915d963107eb337b2c7c5dd092354ea3c66f1b47";
    })
  ];

  prePatch = optionalString (type == "bootstrap") ''
    ! test -e gmp
    unpackFile '${gmp.src}'
    mv gmp-* gmp
    ! test -e mpc
    unpackFile '${libmpc.src}'
    mv mpc-* mpc
    ! test -e mpfr
    unpackFile '${mpfr.src}'
    mv mpfr-* mpfr
  '';

  configureFlags = [
    "--target=${target}"
    "--${boolEn (type != "bootstrap")}-shared"
    "--enable-host-shared"
    "--${boolEn (type != "bootstrap")}-gcov"
    "--disable-multilib"
    "--${boolEn (type != "bootstrap")}-threads"
    "--disable-maintainer-mode"
    "--disable-bootstrap"
    "--enable-languages=c,c++"
    "--${boolEn (type != "bootstrap")}-libsanitizer"
    (optional (type == "bootstrap") "--disable-libssp")
    "--${boolEn (type != "bootstrap")}-libquadmath"
    "--${boolEn (type != "bootstrap")}-libgomp"
    "--${boolEn (type != "bootstrap")}-libvtv"
    "--${boolEn (type != "bootstrap")}-libatomic"
    "--${boolEn (type != "bootstrap")}-libitm"
    "--${boolEn (type != "bootstrap")}-libmpx"
    "--${boolEn (type != "bootstrap")}-libhsail-rt"
    "--${boolEn (type != "bootstrap")}-libstdcxx"
    "--disable-werror"
    "--enable-checking=${checking}"
    "--${boolEn (type != "bootstrap")}-nls"
    (optional (type == "bootstrap") "--disable-decimal-float")
    "--${boolEn (type != "bootstrap")}-lto"
    "--with-glibc-version=2.28"
    (optional (type == "bootstrap") "--without-headers")
    (optional (type == "bootstrap") "--with-newlib")
    "--with-build-time-tools=${binutils}/bin"
    "--${boolWt (type != "bootstrap")}-system-libunwind"
    "--${boolWt (type != "bootstrap")}-system-zlib"
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-local-prefix=/no-such-path/local-prefix"
      "--with-native-system-header-dir=${nativeHeaders}"
      "--with-debug-prefix-map=$NIX_BUILD_TOP=/no-such-path"
    )

    mkdir -v build
    cd build
    configureScript='../configure'
  '';

  preBuild = ''
    sed -i '/^TOPLEVEL_CONFIGURE_ARGUMENTS=/d' Makefile
  '' + optionalString (type != "bootstrap") ''
    # Our compiler needs to get libc objects
    # Normally using -B${libc}/lib works but libtool filters
    # that out for some of the runtime library builds
    mkdir gcc
    ln -sv "${libc}"/lib/*.o gcc/

    # Our libc needs linux/limits.h for its limits.h
    makeFlagsArray+=("CPPFLAGS_FOR_TARGET=-idirafter ${linux-headers}/include")
    flags=(
      "-idirafter" "${linux-headers}/include"

      # Libc library configs
      "-L${libc}/lib"
      "-Wl,-dynamic-linker=$(echo ${libc}/lib/ld-linux-*.so*)"
      "-Wl,-rpath=${libc}/lib"
    )
    oldifs="$IFS"
    IFS=" "
    makeFlagsArray+=("CFLAGS_FOR_TARGET=''${flags[*]}")
    makeFlagsArray+=("CXXFLAGS_FOR_TARGET=''${flags[*]}")
    makeFlagsArray+=("LDFLAGS_FOR_TARGET=''${flags[*]}")
    IFS="$oldifs"
  '';

  postInstall = optionalString (type == "bootstrap") ''
    # GCC won't include our libc limits.h if we don't fix it
    cat ../gcc/{limitx.h,glimits.h,limity.h} >"$out"/lib/gcc/*/*/include-fixed/limits.h

    # CC does not get installed for some reason
    ln -srv "$out"/bin/${target}-gcc "$out"/bin/${target}-cc

    # Ensure we have all of the non-prefixed tools
    for bin in "$out"/bin/${target}-*; do
      base="$(basename "$bin")"
      tool="$out/bin/''${base:${toString (stringLength (target + "-"))}}"
      rm -fv "$tool"
      ln -srv "$bin" "$tool"
    done
  '' + optionalString (type != "bootstrap") ''
    # CC does not get installed for some reason
    ln -srv "$out"/bin/gcc "$out"/bin/cc
  '' + ''
    # Hash the tools and deduplicate
    declare -A binMap
    for bin in "$out"/bin/*; do
      if [ -L "$bin" ]; then
        continue
      fi
      checksum="$(cksum "$bin" | cut -d ' ' -f1)"
      oBin="''${binMap["$checksum"]}"
      if [ -z "$oBin" ]; then
        binMap["$checksum"]="$bin"
      elif cmp "$bin" "$oBin"; then
        rm "$bin"
        ln -srv "$oBin" "$bin"
      fi
    done

    # We don't need the install-tools for anything
    # They sometimes hold references to interpreters
    rm -rv "$out"/libexec/gcc/*/*/install-tools

    # Make sure the cc-wrapper doesn't pick this up automagically
    mkdir -p "$out"/nix-support
    touch "$out"/nix-support/cc-wrapper-ignored
  '';

  preFixup = optionalString (type != "full") ''
    # Remove unused files from bootstrap
    rm -r "$out"/share
  '' + optionalString (type != "bootstrap") ''
    # We don't need the libtool archive files so purge them
    # TODO: Fixup libtool archives so we don't reference an old compiler
    find "$out"/lib* -name '*'.la -delete
  '';

  # We want static libgcc_s
  disableStatic = false;

  passthru = {
    inherit version;
    impl = "gcc";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
} // optionalAttrs (type != "bootstrap") {
  # Ensure we don't depend on anything unexpected
  allowedReferences = [
    "out"
    gmp
    isl
    libc
    libmpc
    linux-headers
    mpfr
    zlib
  ] ++ stdenv.cc.runtimeLibcxxLibs;
})
