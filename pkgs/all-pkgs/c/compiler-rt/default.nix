{ stdenv
, cmake
, fetchurl
, llvm
, ninja
, python3

, target_cc
}:

let
  inherit (llvm)
    version
    srcs
    srcUrls;
in
(stdenv.override { cc = null; }).mkDerivation {
  name = "compiler-rt-${version}";

  src = fetchurl {
    urls = srcUrls "compiler-rt";
    inherit (srcs.compiler-rt)
      sha256;
  };

  nativeBuildInputs = [
    cmake
    llvm
    ninja
    python3
  ];

  preConfigure = ''
    #ln -sv '${stdenv.cc}' "$NIX_BUILD_TOP"/cc
    ln -sv '${target_cc}' "$NIX_BUILD_TOP"/cc
    export PATH="$PATH:$NIX_BUILD_TOP/cc/bin"
  '';

  failureHook = ''
    cat "$NIX_BUILD_TOP"/build/CMakeFiles/CMakeError.log
    cat "$NIX_BUILD_TOP"/build/CMakeFiles/CMakeOutput.log
  '';

  cmakeFlags = [
    "-DCMAKE_C_COMPILER_WORKS=1"
    "-DCMAKE_CXX_COMPILER_WORKS=1"
    "-DCMAKE_AR=${llvm.bin}/bin/llvm-ar"
    "-DCOMPILER_RT_BUILD_SANITIZERS=OFF"
    "-DCOMPILER_RT_BUILD_XRAY=OFF"
    "-DCOMPILER_RT_BUILD_LIBFUZZER=OFF"
    "-DCOMPILER_RT_BUILD_PROFILE=OFF"
  ];

  preBuild = ''
    export NIX_LDFLAGS="$NIX_LDFLAGS -rpath $lib/lib"
    rm "$NIX_BUILD_TOP"/cc
    ln -sv '${target_cc}' "$NIX_BUILD_TOP"/cc
  '';

  preFixup = ''
    strip() { '${llvm.bin}/bin/llvm-strip' "$@"; }
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
