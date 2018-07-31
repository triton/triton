{ stdenv
, cmake
, fetchurl
, ninja
, python3Packages

, cyrus-sasl
, icu
, openssl
, snappy
, zlib
}:

let
  version = "1.12.0";
in
stdenv.mkDerivation rec {
  name = "mongo-c-driver-${version}";

  src = fetchurl {
    url = "https://github.com/mongodb/mongo-c-driver/releases/download"
      + "/${version}/${name}.tar.gz";
    sha256 = "e5924207f6ccbdf74a9b95305b150e96b3296a71f2aafbb21e647dc28d580c68";
  };

  nativeBuildInputs = [
    cmake
    ninja
    python3Packages.sphinx
  ];

  buildInputs = [
    cyrus-sasl
    icu
    openssl
    snappy
    zlib
  ];

  cmakeFlags = [
    "-DENABLE_TESTS=OFF"
    "-DENABLE_EXAMPLES=OFF"
    "-DENABLE_SRV=ON"
    "-DENABLE_CRYPTO_SYSTEM_PROFILE=ON"
    "-DENABLE_MAN_PAGES=ON"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
