{ stdenv
, fetchurl

, zlib
}:

let
  version = "3.3.0";
in
stdenv.mkDerivation rec {
  name = "protobuf-cpp-${version}";

  src = fetchurl {
    url = "https://github.com/google/protobuf/releases/download/v${version}/${name}.tar.gz";
    multihash = "QmRfu3z6DpPcQNsKDzhda9ATRC3QyfiXLYPaNAnkteSeYv";
    sha256 = "578a2589bf9258adb03245dec5d624b61536867ebb732dbb8aeb30d96b0ada1f";
  };

  buildInputs = [
    zlib
  ];

  configureFlags = [
    "--with-zlib"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
