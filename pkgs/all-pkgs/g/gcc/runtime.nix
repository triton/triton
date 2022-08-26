{ stdenv
, lib
, cc
, gcc
, gcc_lib

, libsan ? true
, preConfigure ? ""
, failureHook ? null
}:

let
  inherit (lib)
    boolEn
    optionalString
    optionals;
in
(stdenv.override { cc = null; }).mkDerivation ({
  name = "gcc-runtime-${gcc.version}";

  src = gcc.src;

  patches = gcc.patches;

  nativeBuildInputs = [
    cc
  ];

  configureFlags = gcc.commonConfigureFlags ++ [
    "--with-system-libunwind"
    "--${boolEn libsan}-libsanitizer"
  ];

  postPatch = ''
    # Make configure think we vendored these sources
    # We don't actully need them for target tools
    mkdir -p mpfr/src mpc gmp

    # Don't build libgcc or the host gcc tool
    sed -i 's,^maybe-all-gcc: .*,maybe-all-gcc:,' Makefile.in
    sed -i 's,^\(maybe-\(all\|install\)-target-libgcc:\) .*,\1,' Makefile.in

    # Don't try and use a gcc binary from our current build directory
    # Always use the one we built previously
    sed -i '/^[ ]*ok=/s,yes,no,' configure
  '';

  preConfigure = preConfigure + ''
    mkdir -v build
    cd build
    tar xf '${gcc_lib.internal}'/build.tar.xz
    find . -type f -exec sed -i "s,/build-dir,$NIX_BUILD_TOP,g" {} \;
    configureScript='../configure'
  '';

  preBuild = ''
    buildFlagsArray+=(
      RAW_CXX_FOR_TARGET="$CC"
      COMPILER_AS_FOR_TARGET="$($CC -print-prog-name=as)"
      COMPILER_LD_FOR_TARGET="$($CC -print-prog-name=ld)"
      COMPILER_NM_FOR_TARGET="$($CC -print-prog-name=nm)"
    )
  '' + lib.optionalString (stdenv.targetSystem == "i686-linux") ''
    # Override bad arch options passed in for libatomic
    export CC_WRAPPER_CFLAGS+=" -march=prescott -mtune=prescott"
  '';

  buildFlags = [
    "all-target"
  ];

  installTargets = [
    "install-target"
  ];

  postInstall = ''
    mv "$dev"/lib/gcc/*/*/include/* "$dev"/include
    rm -rv "$dev"/lib/gcc

    mkdir -p "$lib"/lib "$libcxx"/lib "$libssp"/lib
    mv "$dev"/lib*/libstdc++*.so* "$libcxx"/lib
    rm "$libcxx"/lib/*.py
    mv "$dev"/lib*/libssp.so* "$libssp"/lib
  '' + optionalString libsan ''
    mkdir -p "$libsan"/lib
    mv "$dev"/lib*/*san.so* "$libsan"/lib
  '' + ''
    mv "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$libcxx"/lib/* "$libssp"/lib/* "$dev"/lib
  '' + optionalString libsan ''
    ln -sv "$libsan"/lib/* "$dev"/lib
  '' + ''
    mkdir -p "$dev"/nix-support
    echo "-idirafter $dev/include" >>"$dev"/nix-support/stdinc
    echo "-L$dev/lib" >>"$dev"/nix-support/ldflags
    cxxinc="$(dirname "$(dirname "$dev"/include/c++/*/*/bits/c++config.h)")"
    echo "-idirafter $(dirname "$cxxinc")" >>"$dev"/nix-support/stdincxx
    echo "-idirafter $cxxinc" >>"$dev"/nix-support/stdincxx
  '';

  preFixup = ''
    rm -rv "$dev"/share
  '';

  outputs = [
    "dev"
    "lib"
    "libcxx"
    "libssp"
  ] ++ optionals libsan [
    "libsan"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux ++
      x86_64-linux ++
      powerpc64le-linux;
  };
} // (if failureHook != null then { inherit failureHook; } else { }))
