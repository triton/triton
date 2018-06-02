{ stdenv
, cmake
, fetchurl
, ninja
, python3Packages

, cyrus-sasl
, openssl
, snappy
, zlib
}:

let
  version = "1.10.1";
in
stdenv.mkDerivation rec {
  name = "mongo-c-driver-${version}";

  src = fetchurl {
    url = "https://github.com/mongodb/mongo-c-driver/releases/download"
      + "/${version}/${name}.tar.gz";
    sha256 = "630e83bfc97114a9936f0b6871bfd593b538839caf1d3f93c8038148d1b9a4d6";
  };

  nativeBuildInputs = [
    cmake
    ninja
    python3Packages.sphinx
  ];

  buildInputs = [
    cyrus-sasl
    openssl
    snappy
    zlib
  ];

  cmakeFlags = [
    "-DENABLE_TESTS=OFF"
    "-DENABLE_EXAMPLES=OFF"
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
