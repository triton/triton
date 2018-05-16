{ stdenv
, cmake
, fetchurl
, lib
, ninja

, libebml
}:

stdenv.mkDerivation rec {
  name = "libmatroska-1.4.9";

  src = fetchurl {
    url = "https://dl.matroska.org/downloads/libmatroska/${name}.tar.xz";
    multihash = "QmPYuyMxdLtLryvTsSygmZBgtqi8YFyuz7jR8n6kLoAT9j";
    sha256 = "38a61dd5d87c070928b5deb3922b63b2b83c09e2e4a10f9393eecb6afa9795c8";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    libebml
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
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
