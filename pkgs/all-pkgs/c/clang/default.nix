{ stdenv
, cmake
, fetchTritonPatch
, fetchurl
, ninja
, python3

, llvm
, perl
, z3
}:

let
  inherit (llvm)
    version
    srcs
    srcUrls;
in
stdenv.mkDerivation {
  name = "clang-${version}";

  src = fetchurl {
    urls = srcUrls "cfe";
    inherit (srcs.cfe)
      sha256;
  };

  nativeBuildInputs = [
    cmake
    ninja
    python3
  ];

  buildInputs = [
    llvm
    perl
    z3
  ];

  patches = [
    (fetchTritonPatch {
      rev = "ddebe9803d7749e08b04ef98c9d6514d520df1ee";
      file = "c/clang/0001-Remove-hard-coded-search-paths.patch";
      sha256 = "61ab7ac43b9487b068c6c538437d1a0e368057f1b56d2ecbae79764d6ae50d41";
    })
  ];

  cmakeFlags = [
    "-DCLANG_ANALYZER_Z3_INSTALL_DIR=${z3}"
  ];

  preBuild = ''
    export NIX_LDFLAGS="$NIX_LDFLAGS -rpath $lib/lib"
  '';

  postInstall = ''
    mkdir -p "$lib"/lib
    mv "$dev"/lib/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib

    mkdir -p "$bin"
    mv -v "$dev"/bin "$bin"
    ln -sv clang++ "$bin"/bin/c++
    ln -sv clang "$bin"/bin/cc
    mv "$dev"/libexec "$bin"

    mkdir -p "$man"/share
    mv -v "$dev"/share/man "$man"/share

    mkdir -p "$cc_headers"
    mv "$dev"/lib/clang/*/include "$cc_headers"
    rmdir "$dev"/lib/clang/*
    rmdir "$dev"/lib/clang
  '';

  prefix = placeholder "dev";

  outputs = [
    "dev"
    "bin"
    "man"
    "lib"
    "cc_headers"
  ];

  passthru = {
    cc = "clang";
    cxx = "clang++";
    optFlags = [ ];
    prefixMapFlag = "debug-prefix-map";
    canStackClashProtect = false;
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
