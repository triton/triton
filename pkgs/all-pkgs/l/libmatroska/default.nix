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
  name = "libmatroska-1.4.8";

  src = fetchurl {
    url = "https://dl.matroska.org/downloads/libmatroska/${name}.tar.xz";
    multihash = "QmTQvHwzCcV58uQ1eSvFXW6vQyvA3K5rXqLTZjXnYERg1o";
    sha256 = "d8c72b20d4c5bf888776884b0854f95e74139b5267494fae1f395f7212d7c992";
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
