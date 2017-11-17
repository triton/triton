{ stdenv
, fetchurl
, perl

, cyrus-sasl
, libbson
, openssl
}:

let
  version = "1.8.2";
in
stdenv.mkDerivation rec {
  name = "mongo-c-driver-${version}";

  src = fetchurl {
    url = "https://github.com/mongodb/mongo-c-driver/releases/download"
      + "/${version}/${name}.tar.gz";
    sha256 = "2929e415b157c48e867e9d7eda4a11920e8f8763f33af5fbcdb4f4fe316f7c5e";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    cyrus-sasl
    libbson
    openssl
  ];

  configureFlags = [
    "--disable-examples"
    "--disable-tests"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
