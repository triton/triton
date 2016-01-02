{ stdenv, fetchurl, perl }:

stdenv.mkDerivation rec {
  name = "libbson-${version}";
  version = "1.3.0";

  src = fetchurl {
    url = "https://github.com/mongodb/libbson/releases/download/${version}/${name}.tar.gz";
    sha256 = "1b9hbxfljbqpjslmsvmvlgmll57l9d2ylgcrc7mi5yyf9r92i1k3";
  };

  nativeBuildInputs = [ perl ];

  meta = with stdenv.lib; {
    description = "A C Library for parsing, editing, and creating BSON documents";
    homepage = "https://github.com/mongodb/libbson";
    license = licenses.asl20;
    platforms = platforms.all;
  };
}
