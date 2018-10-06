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
  version = "1.13.0";
in
stdenv.mkDerivation rec {
  name = "mongo-c-driver-${version}";

  src = fetchurl {
    url = "https://github.com/mongodb/mongo-c-driver/releases/download"
      + "/${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "25164e03b08baf9f2dd88317f1a36ba36b09f563291a7cf241f0af8676155b8d";
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

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = { };
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
