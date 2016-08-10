{ stdenv
, fetchurl

, libebml
}:

let
  inherit (stdenv.lib)
    optionals;
in

stdenv.mkDerivation rec {
  name = "libmatroska-1.4.5";

  src = fetchurl {
    url = "https://dl.matroska.org/downloads/libmatroska/${name}.tar.bz2";
    sha256 = "79023fa46901e5562b27d93a9dd168278fa101361d7fd11a35e84e58e11557bc";
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
