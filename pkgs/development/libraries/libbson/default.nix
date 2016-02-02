{ stdenv, fetchurl, perl }:

stdenv.mkDerivation rec {
  name = "libbson-${version}";
  version = "1.3.2";

  src = fetchurl {
    url = "https://github.com/mongodb/libbson/releases/download/${version}/${name}.tar.gz";
    sha256 = "1ir5pbq825isxlhqc8nwxxly2aif4v3m4yjx0zifqvdxggzn8gbk";
  };

  nativeBuildInputs = [ perl ];

  meta = with stdenv.lib; {
    description = "A C Library for parsing, editing, and creating BSON documents";
    homepage = "https://github.com/mongodb/libbson";
    license = licenses.asl20;
    platforms = platforms.all;
  };
}
