{ stdenv
, cmake
, fetchTritonPatch
, fetchurl
, ninja
, python3

, libffi
, libxml2

, channel
}:

let
  sources = import ./sources.nix;

  inherit (sources."${channel}")
    version
    patches
    srcs;

  inherit (stdenv.lib)
    flip
    makeOverridable
    mapAttrsToList;
in
stdenv.mkDerivation {
  name = "llvm-${version}";

  src = fetchurl {
    urls = [
      "https://releases.llvm.org/${version}/llvm-${version}.src.tar.xz"
      "https://distfiles.macports.org/llvm/llvm-${version}.src.tar.xz"
    ];
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
  ];

  patches = map (d: fetchTritonPatch d) patches;

  postPatch = ''
    # Remove impurities from llvm-config
    sed -i 's,@LLVM_.*_ROOT@,/no-such-path,g' tools/llvm-config/BuildVariables.inc.in

    # Fixup directories in llvm-config
    sed \
      -e "s,ActiveBinDir =.*;,ActiveBinDir = \"$bin/bin\";," \
      -e "/SharedDir =/aSharedDir = \"$lib/lib\";" \
      -i tools/llvm-config/llvm-config.cpp
  '';

  preConfigure = ''
    prefix="$dev"
  '';

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"

    "-DLLVM_INCLUDE_EXAMPLES=OFF"
    "-DLLVM_BUILD_TESTS=OFF"
    "-DLLVM_ENABLE_RTTI=ON"
    "-DLLVM_INSTALL_UTILS=ON"  # Needed by rustc
    "-DLLVM_ENABLE_FFI=ON"

    # TODO: Figure out how to make the single shared library work
    # for external builds
    "-DLLVM_BUILD_LLVM_DYLIB=ON"
    "-DLLVM_LINK_LLVM_DYLIB=ON"
  ];

  preBuild = ''
    export NIX_LDFLAGS="$NIX_LDFLAGS -rpath $lib/lib"
  '';

  postInstall = ''
    mkdir -p "$lib"/lib
    mv -v "$dev"/lib/*.so* "$lib"/lib

    mkdir -p "$bin"/bin
    mv -v "$dev"/bin/* "$bin"/bin
    mv -v "$bin"/bin/llvm-config "$dev"/bin

    mkdir -p "$dev"/nix-support
    echo "$lib" >"$dev"/nix-support/propagated-native-build-inputs
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
