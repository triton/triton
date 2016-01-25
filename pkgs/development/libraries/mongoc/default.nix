{ stdenv, fetchurl
, perl
, libbson
, openssl
, cyrus_sasl
}:

stdenv.mkDerivation rec {
  name = "mongo-c-driver-${version}";
  version = "1.3.1";

  src = fetchurl {
    url = "https://github.com/mongodb/mongo-c-driver/releases/download/${version}/${name}.tar.gz";
    sha256 = "0k4yyqq3a7j432nfh2c8jhl2aa33bnw1b13bs8pmkqqgxaaq2gld";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    libbson
    openssl
    cyrus_sasl
  ];

  configureFlags = [
    "--enable-ssl"
    "--enable-sasl"
  ];

  meta = with stdenv.lib; {
    description = "The official C client library for MongoDB";
    homepage = "https://github.com/mongodb/mongo-c-driver";
    license = licenses.asl20;
    platforms = platforms.all;
  };
}
