{ stdenv
, fetchurl
, perl

, cyrus-sasl
, libbson
, openssl
}:

let
  version = "1.5.0";
in
stdenv.mkDerivation rec {
  name = "mongo-c-driver-${version}";

  src = fetchurl {
    url = "https://github.com/mongodb/mongo-c-driver/releases/download"
      + "/${version}/${name}.tar.gz";
    sha256 = "b9b7514052fe7ec40786d8fc22247890c97d2b322aa38c851bba986654164bd6";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    cyrus-sasl
    libbson
    openssl
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
