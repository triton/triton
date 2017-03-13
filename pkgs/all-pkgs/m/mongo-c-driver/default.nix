{ stdenv
, fetchurl
, perl

, cyrus-sasl
, libbson
, openssl
}:

let
  version = "1.6.1";
in
stdenv.mkDerivation rec {
  name = "mongo-c-driver-${version}";

  src = fetchurl {
    url = "https://github.com/mongodb/mongo-c-driver/releases/download"
      + "/${version}/${name}.tar.gz";
    sha256 = "1bdfb27944c6da8e56da209a5d56efac70df1f8c4ca4498b46f75bf3f9360898";
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
