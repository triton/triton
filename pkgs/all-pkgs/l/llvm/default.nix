{ stdenv
, cmake
, fetchTritonPatch
, fetchurl
, ninja
, python3

, libffi
, libxml2
, ncurses
, zlib

, channel
}:

let
  sources = import ./sources.nix;

  inherit (sources."${channel}")
    version
    patches
    srcs;

  srcUrls = proj: [
    "https://github.com/llvm/llvm-project/releases/download/llvmorg-${version}/${proj}-${version}.src.tar.xz"
    "https://releases.llvm.org/${version}/${proj}-${version}.src.tar.xz"
    "https://distfiles.macports.org/llvm/${proj}-${version}.src.tar.xz"
  ];

  inherit (stdenv.lib)
    flip
    makeOverridable
    mapAttrsToList;
in
stdenv.mkDerivation {
  name = "llvm-${version}";

  src = fetchurl {
    urls = srcUrls "llvm";
    inherit (srcs.llvm)
      sha256;
  };

  nativeBuildInputs = [
    cmake
    ninja
    python3
  ];

  buildInputs = [
    libffi
    libxml2
    ncurses
    zlib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "b178552fe5e7431bfa98025cb8e4fe2e4927bd69";
      file = "l/llvm/fix-llvm-config.patch";
      sha256 = "7cbe2b2d1127c0995cb1af5d7d758e1a9a600ee17045f3a3341a68726ba8f0e8";
    })
  ];

  postPatch = ''
    # Remove impurities from llvm-config
    sed -i 's,@LLVM_.*_ROOT@,/no-such-path,g' tools/llvm-config/BuildVariables.inc.in

    # Fixup directories in llvm-config
    sed \
      -e "s,ActiveBinDir =.*;,ActiveBinDir = \"$bin/bin\";," \
      -e "/SharedDir =/aSharedDir = \"$lib/lib\";" \
      -i tools/llvm-config/llvm-config.cpp
  '';

  cmakeFlags = [
    "-DLLVM_INSTALL_UTILS=ON"  # Needed by rustc
    "-DLLVM_ENABLE_FFI=ON"
    "-DLLVM_INCLUDE_EXAMPLES=OFF"
    "-DLLVM_INCLUDE_TESTS=OFF"
    "-DLLVM_INCLUDE_GO_TESTS=OFF"
    "-DLLVM_INCLUDE_BENCHMARKS=OFF"
    "-DLLVM_INCLUDE_DOCS=OFF"
    "-DLLVM_ENABLE_OCAMLDOC=OFF"
    "-DLLVM_ENABLE_BINDINGS=OFF"
    "-DLLVM_BUILD_EXTERNAL_COMPILER_RT=ON"
    "-DLLVM_LINK_LLVM_DYLIB=ON"
    "-DLLVM_BUILD_LLVM_DYLIB=ON"
    "-DLLVM_OPTIMIZED_TABLEGEN=ON"

    "-DLLVM_ENABLE_RTTI=ON"
  ];

  preBuild = ''
    export NIX_LDFLAGS="$NIX_LDFLAGS -rpath $lib/lib"
  '';

  postInstall = ''
    mkdir -p "$lib"/lib
    mv -v "$dev"/lib/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib

    mkdir -p "$bin"/bin
    mv -v "$dev"/bin/* "$bin"/bin
    mv -v "$bin"/bin/llvm-config "$dev"/bin
    ln -sv "$bin"/bin/* "$dev"/bin
  '';

  preFixup = ''
    replace_lib() {
      sed -i "s,\\([\";]\\)$1\\([\";]\\),\1$(readlink -f "$2")\2,g" "$dev"/lib/cmake/llvm/LLVMExports.cmake
    }

    replace_lib xml2 '${libxml2}/lib/libxml2.so'
    replace_lib ncurses '${ncurses}/lib/libncurses.so'
    replace_lib z '${zlib}/lib/libz.so'
  '';

  prefix = placeholder "dev";

  outputs = [
    "dev"
    "bin"
    "lib"
  ];

  passthru = {
    inherit
      srcs
      srcUrls
      version;
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
