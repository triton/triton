{ stdenv
, fetch
, fetchTritonPatch
, perl
, groff
, cmake
, ninja
, python
, libffi
, binutils
, libxml2
, valgrind
, ncurses
, version
, zlib
, compiler-rt_src
, libcxxabi
, debugVersion ? false
, enableSharedLibraries ? true
}:

let
  src = fetch "llvm" "1masakdp9g2dan1yrazg7md5am2vacbkb3nahb3dchpc1knr8xxy";
in stdenv.mkDerivation rec {
  name = "llvm-${version}";

  unpackPhase = ''
    unpackFile ${src}
    mv llvm-${version}.src llvm
    sourceRoot=$PWD/llvm
    unpackFile ${compiler-rt_src}
    mv compiler-rt-* $sourceRoot/projects/compiler-rt
  '';

  patches = [
    (fetchTritonPatch {
      rev = "1a001778aab424ecd36774befa1f546b0004c5fc";
      file = "llvm/fix-llvm-config.patch";
      sha256 = "059655c0e6ea5dd248785ffc1b2e6402eeb66544ffe36ff15d76543dd7abb413";
    })
  ];

  nativeBuildInputs = [ perl groff cmake ninja python ];
  buildInputs = [ libxml2 libffi ncurses zlib ];

  # hacky fix: created binaries need to be run before installation
  preBuild = ''
    mkdir -p $out/
    ln -sv $PWD/lib $out
  '';

  cmakeFlags = with stdenv; [
    "-DCMAKE_BUILD_TYPE=${if debugVersion then "Debug" else "Release"}"
    "-DLLVM_INSTALL_UTILS=ON"  # Needed by rustc
    "-DLLVM_BUILD_TESTS=ON"
    "-DLLVM_ENABLE_FFI=ON"
    "-DLLVM_ENABLE_RTTI=ON"
  ] ++ stdenv.lib.optional enableSharedLibraries
    "-DBUILD_SHARED_LIBS=ON"
    ++ stdenv.lib.optional true
    "-DLLVM_BINUTILS_INCDIR=${binutils}/include";

  doCheck = true;

  postBuild = ''
    rm -fR $out

    paxmark m bin/{lli,llvm-rtdyld}

    paxmark m unittests/ExecutionEngine/JIT/JITTests
    paxmark m unittests/ExecutionEngine/MCJIT/MCJITTests
    paxmark m unittests/Support/SupportTests
  '';

  passthru.src = src;

  meta = {
    description = "Collection of modular and reusable compiler and toolchain technologies";
    homepage    = http://llvm.org/;
    license     = stdenv.lib.licenses.bsd3;
    maintainers = with stdenv.lib.maintainers; [ lovek323 raskin viric ];
    platforms   = stdenv.lib.platforms.all;
  };
}
