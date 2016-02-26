{ stdenv, fetch, cmake, ninja, libxml2, libedit, llvm, version, clang-tools-extra_src }:

let
  gcc = if stdenv.cc.isGNU then stdenv.cc.cc else stdenv.cc.cc.gcc;
in stdenv.mkDerivation {
  name = "clang-${version}";

  unpackPhase = ''
    unpackFile ${fetch "cfe" "0x065d0w9b51xvdjxwfzjxng0gzpbx45fgiaxpap45ragi61dqjn"}
    mv cfe-${version}.src clang
    sourceRoot=$PWD/clang
    unpackFile ${clang-tools-extra_src}
    mv clang-tools-extra-* $sourceRoot/tools/extra
  '';

  nativeBuildInputs = [ cmake ninja ];
  buildInputs = [ libedit libxml2 llvm ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_CXX_FLAGS=-std=c++11"

    # Maybe with compiler-rt this won't be needed?
    "-DGCC_INSTALL_PREFIX=${gcc}"
    "-DC_INCLUDE_DIRS=${stdenv.cc.libc}/include"
  ];

  patches = [ ./purity.patch ];

  postPatch = ''
    sed -i -e 's/Args.hasArg(options::OPT_nostdlibinc)/true/' lib/Driver/Tools.cpp
    sed -i -e 's/DriverArgs.hasArg(options::OPT_nostdlibinc)/true/' lib/Driver/ToolChains.cpp
  '';

  # Clang expects to find LLVMgold in its own prefix
  # Clang expects to find sanitizer libraries in its own prefix
  postInstall = ''
    ln -sv ${llvm}/lib/LLVMgold.so $out/lib
    ln -sv ${llvm}/lib/clang/${version}/lib $out/lib/clang/${version}/
    ln -sv $out/bin/clang $out/bin/cpp
  '';

  passthru = {
    isClang = true;
    inherit gcc;  # WAT????? Why does cc-wrapper need this here
  };

  meta = {
    description = "A c, c++, objective-c, and objective-c++ frontend for the llvm compiler";
    homepage    = http://llvm.org/;
    license     = stdenv.lib.licenses.bsd3;
    platforms   = stdenv.lib.platforms.all;
  };
}
