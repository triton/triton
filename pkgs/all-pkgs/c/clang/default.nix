{ stdenv
, cmake
, fetchTritonPatch
, fetchurl
, ninja
, python3

, llvm_split
, z3
}:

let
  inherit (llvm_split)
    version
    srcs;
in
stdenv.mkDerivation {
  name = "clang-${version}";

  src = fetchurl {
    urls = [
      "https://releases.llvm.org/${version}/cfe-${version}.src.tar.xz"
      "https://distfiles.macports.org/llvm/cfe-${version}.src.tar.xz"
    ];
    inherit (srcs.cfe)
      sha256;
  };

  nativeBuildInputs = [
    cmake
    #ninja
    python3
  ];

  buildInputs = [
    llvm_split
    z3
  ];

  preConfigure = ''
    prefix="$dev"
  '';

  cmakeFlags = [
    "-DCLANG_ANALYZER_Z3_INSTALL_DIR=${z3}"
  ];

  preBuild = ''
    export NIX_LDFLAGS="$NIX_LDFLAGS -rpath $lib/lib"
    export NIX_DEBUG=1
  '';

  makeFlags = [
    "VERBOSE=1"
  ];

  postInstall = ''
    mkdir -p "$lib"/lib
    mv "$dev"/lib/*.so* "$lib"/lib
    mv "$dev"/libexec "$lib"
    ln -sv "$lib"/libexec "$dev"

    mkdir -p "$bin"
    mv -v "$dev"/bin "$bin"
    ln -sv "$lib"/libexec "$bin"

    mkdir -p "$man"/share
    mv -v "$dev"/share/man "$man"/share

    mkdir -p "$dev"/nix-support
    echo "$lib" >"$dev"/nix-support/propagated-native-build-inputs
  '';

  outputs = [
    "dev"
    "bin"
    "man"
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
