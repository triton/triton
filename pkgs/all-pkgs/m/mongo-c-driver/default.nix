{ stdenv
, fetchurl
, perl

, cyrus-sasl
, libbson
, openssl
}:

let
  version = "1.5.3";
in
stdenv.mkDerivation rec {
  name = "mongo-c-driver-${version}";

  src = fetchurl {
    url = "https://github.com/mongodb/mongo-c-driver/releases/download"
      + "/${version}/${name}.tar.gz";
    sha256 = "c617775b42ad3cd90f9f417bdf1fd141aef930d0b0f11ec1a1da1eeb7bc158e7";
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
