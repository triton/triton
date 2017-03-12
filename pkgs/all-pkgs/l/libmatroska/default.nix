{ stdenv
, fetchurl
, lib

, libebml
}:

let
  inherit (lib)
    optionals;
in
stdenv.mkDerivation rec {
  name = "libmatroska-1.4.7";

  src = fetchurl {
    url = "https://dl.matroska.org/downloads/libmatroska/${name}.tar.bz2";
    multihash = "QmP28YKW2UhrqK7FDcd8h4D8YVXJx2SnujrhMwv2YzteBZ";
    sha256 = "46441eb3bae9f970f68affaa211dd74302a7072dcd2becfb1114da11b66525fa";
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

  meta = with lib; {
    description = "A library to parse Matroska files";
    homepage = http://matroska.org/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
