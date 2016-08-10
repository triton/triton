{ stdenv
, cmake
, fetchTritonPatch
, fetchurl
, ninja
, perl
, python
, swig

, libedit
, libffi
, libtirpc
, libxml2
, ncurses
, zlib
}:

let
  sources = import ./sources.nix;

  gcc = if stdenv.cc.isGNU then stdenv.cc.cc else stdenv.cc.cc.gcc;

  inherit (stdenv.lib)
    flip
    makeOverridable
    mapAttrsToList;

  srcs = flip mapAttrsToList sources.srcs (n: d:
    let
      version = d.version or sources.version;
    in makeOverridable fetchurl {
      url = "http://llvm.org/releases/${version}/${n}-${version}.src.tar.xz";
      inherit (d) sha256;
    }
  );
in
stdenv.mkDerivation {
  name = "llvm-${sources.version}";

  srcs = flip map srcs (src: src.override {
    allowHashOutput = false;
  });

  sourceRoot = "llvm-${sources.version}.src";

  nativeBuildInputs = [
    cmake
    ninja
    perl
    python
    swig
  ];

  buildInputs = [
    libedit
    libffi
    libtirpc
    libxml2
    ncurses
    zlib
  ];

  prePatch = ''
    mkdir -p projects
    ls .. \
      | grep '[0-9]\.[0-9]\.[0-9]' \
      | grep -v 'llvm' \
      | sed 's,\(.*\)-[0-9]\.[0-9]\.[0-9].src$,../\0 projects/\1,g' \
      | xargs -n 2 mv
    mv projects/cfe tools/clang
    mv projects/clang-tools-extra tools/clang/tools/extra
  '';

  patches = [
    (fetchTritonPatch {
      rev = "1a001778aab424ecd36774befa1f546b0004c5fc";
      file = "llvm/fix-llvm-config.patch";
      sha256 = "059655c0e6ea5dd248785ffc1b2e6402eeb66544ffe36ff15d76543dd7abb413";
    })
  ];

  cmakeFlags = with stdenv; [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_CXX_FLAGS=-std=c++11"

    "-DLLVM_INCLUDE_EXAMPLES=OFF"
    "-DLLVM_BUILD_TESTS=ON"
    "-DLLVM_ENABLE_RTTI=ON"
    "-DLLVM_INSTALL_UTILS=ON"  # Needed by rustc
    "-DLLVM_ENABLE_FFI=ON"

    # Not sure why these are needed
    "-DGCC_INSTALL_PREFIX=${gcc}"
    "-DC_INCLUDE_DIRS=${stdenv.cc.libc}/include"

    "-DLIBCXXABI_USE_LLVM_UNWINDER=ON"

    # TODO: Figure out how to make the single shared library work
    # for external builds
    "-DLLVM_BUILD_LLVM_DYLIB=ON"
    "-DLLVM_LINK_LLVM_DYLIB=ON"
  ];

  doCheck = true;

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I$(pwd)/tools/clang/include"
  '';

  passthru = {
    isClang = true;
    inherit gcc;

    srcVerifications = flip map srcs (src: src.override {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "11E5 21D6 4698 2372 EB57  7A1F 8F08 71F2 0211 9294";
    });
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
