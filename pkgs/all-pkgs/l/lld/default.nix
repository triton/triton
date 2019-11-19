{ stdenv
, cmake
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
  name = "lld-${version}";

  src = fetchurl {
    urls = srcUrls "lld";
    inherit (srcs.lld)
      sha256;
  };

  nativeBuildInputs = [
    cmake
    ninja
    python3
  ];

  buildInputs = [
    llvm
  ];

  postInstall = ''
    mkdir -p "$bin"
    mv -v "$dev"/bin "$bin"
    ln -sv lld "$bin"/bin/ld
  '';

  prefix = placeholder "dev";

  outputs = [
    "dev"
    "bin"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
