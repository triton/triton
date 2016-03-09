{ stdenv
, fetchurl

, libebml
}:

with {
  inherit (stdenv.lib)
    optionals;
};

stdenv.mkDerivation rec {
  name = "libmatroska-1.4.4";

  src = fetchurl {
    url = "http://dl.matroska.org/downloads/libmatroska/${name}.tar.bz2";
    sha256 = "1mvb54q3gag9dj0pkwci8w75gp6mm14gi85y0ld3ar1rdngsmvyk";
  };

  buildInputs = [
    libebml
  ];

  makeFlags = [
    "prefix=$(out)"
    "LIBEBML_INCLUDE_DIR=${libebml}/include"
    "LIBEBML_LIB_DIR=${libebml}/lib"
  ] ++ optionals stdenv.cc.isClang [
    "CXX=clang++"
  ];

  meta = with stdenv.lib; {
    description = "A library to parse Matroska files";
    homepage = http://matroska.org/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
