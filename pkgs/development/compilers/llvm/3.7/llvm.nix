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
}:

let
  src = fetch "llvm" "1masakdp9g2dan1yrazg7md5am2vacbkb3nahb3dchpc1knr8xxy";
in stdenv.mkDerivation rec {
  name = "llvm-${version}";

  inherit src;

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

    # Part of the shared library TODO
    #(fetchTritonPatch {
    #  rev = "b8eb01f3c7b7ad707c8877e9e577b04a68e15707";
    #  file = "llvm/llvm-config-shared-link.patch";
    #  sha256 = "95c1f0d83f5195260f6acca60acc2605bb2ec1a5b106c138239e36a84e15557e";
    #})
  ];

  nativeBuildInputs = [ perl groff cmake ninja python ];
  buildInputs = [ libxml2 libffi ncurses zlib ];

  # hacky fix: created binaries need to be run before installation
  preBuild = ''
    mkdir -p $out/
    ln -sv $PWD/lib $out
  '';

  cmakeFlags = with stdenv; [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DLLVM_INCLUDE_EXAMPLES=OFF"
    "-DLLVM_BUILD_TESTS=ON"
    "-DLLVM_ENABLE_RTTI=ON"
    "-DLLVM_INSTALL_UTILS=ON"  # Needed by rustc
    "-DLLVM_ENABLE_FFI=ON"
    "-DLLVM_ENABLE_LTO=Full"

    # TODO: Figure out how to make the single shared library work
    #"-DLLVM_BUILD_LLVM_DYLIB=ON"
    #"-DLLVM_LINK_LLVM_DYLIB=ON"
  ];

  doCheck = true;

  postBuild = ''
    rm -fR $out
  '';

  meta = {
    description = "Collection of modular and reusable compiler and toolchain technologies";
    homepage    = http://llvm.org/;
    license     = stdenv.lib.licenses.bsd3;
    maintainers = with stdenv.lib.maintainers; [ lovek323 raskin viric ];
    platforms   = stdenv.lib.platforms.all;
  };
}
