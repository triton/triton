{ stdenv
, cmake
, fetchurl
, ninja
}:

stdenv.mkDerivation rec {
  name = "json-c-0.14";

  src = fetchurl {
    url = "https://s3.amazonaws.com/json-c_releases/releases/${name}-nodoc.tar.gz";
    multihash = "QmaFo9Kdn2EooGdriKKNGeV7g9BJpTVPYzEL8V8bFv9Abk";
    sha256 = "99914e644a25201d82ccefa20430f7515c110923360f9ef46755527c02412afa";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = [
    "-DENABLE_RDRAND=ON"
    "-DENABLE_THREADING=ON"
  ];

  meta = with stdenv.lib; {
    description = "A JSON implementation in C";
    homepage = https://github.com/json-c/json-c/wiki;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
