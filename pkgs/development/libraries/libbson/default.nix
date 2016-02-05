{ stdenv, fetchurl, perl }:

stdenv.mkDerivation rec {
  name = "libbson-${version}";
  version = "1.3.3";

  src = fetchurl {
    url = "https://github.com/mongodb/libbson/releases/download/${version}/${name}.tar.gz";
    sha256 = "0k1c58z5dwkhik6aawa5pfvb77g7a426sm55sqhxj0swd26nk637";
  };

  nativeBuildInputs = [ perl ];

  meta = with stdenv.lib; {
    description = "A C Library for parsing, editing, and creating BSON documents";
    homepage = "https://github.com/mongodb/libbson";
    license = licenses.asl20;
    platforms = platforms.all;
  };
}
