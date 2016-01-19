{ stdenv, fetchurl, perl }:

stdenv.mkDerivation rec {
  name = "libbson-${version}";
  version = "1.3.1";

  src = fetchurl {
    url = "https://github.com/mongodb/libbson/releases/download/${version}/${name}.tar.gz";
    sha256 = "0gckh0w05ap3pnlf9cnh3hdrhanz2bn1i5z4inylyirr2aqywz38";
  };

  nativeBuildInputs = [ perl ];

  meta = with stdenv.lib; {
    description = "A C Library for parsing, editing, and creating BSON documents";
    homepage = "https://github.com/mongodb/libbson";
    license = licenses.asl20;
    platforms = platforms.all;
  };
}
