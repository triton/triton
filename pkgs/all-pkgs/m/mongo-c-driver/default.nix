{ stdenv
, fetchurl
, perl

, cyrus-sasl
, libbson
, openssl
}:

let
  version = "1.6.0";
in
stdenv.mkDerivation rec {
  name = "mongo-c-driver-${version}";

  src = fetchurl {
    url = "https://github.com/mongodb/mongo-c-driver/releases/download"
      + "/${version}/${name}.tar.gz";
    sha256 = "d15fe571fb6b0331ceb9139ad724429fef0fdc0444900d7ebd6841590f4f8783";
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
