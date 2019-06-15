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
    ncurses
    zlib
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

    # The cmake files require that we symlink to the real libraries
    for f in "$lib"/lib/*; do
      ln -sv "$f" "$dev"/lib
    done

    mkdir -p "$bin"/bin
    mv -v "$dev"/bin/* "$bin"/bin
    mv -v "$bin"/bin/llvm-config "$dev"/bin

    # The cmake files require that we symlink to the real utilties
    export PATH="$PATH:$bin/bin"
    for f in "$(dirname "$(type -tP llvm-tblgen)")"/*; do
      ln -sv "$f" "$dev"/bin
    done

    mkdir -p "$dev"/nix-support
    substituteAll '${./setup-hook.sh}' "$dev"/nix-support/setup-hook
    echo "$lib" >"$dev"/nix-support/propagated-native-build-inputs
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
  ];

  passthru = {
    inherit
      srcs
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
