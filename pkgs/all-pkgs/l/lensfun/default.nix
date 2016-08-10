{ stdenv
, cmake
, fetchurl

, glib
, libpng
, zlib
}:

stdenv.mkDerivation rec {
  name = "lensfun-0.3.2";

  src = fetchurl {
    url = "mirror://sourceforge/lensfun/${name}.tar.gz";
    sha256 = "ae8bcad46614ca47f5bda65b00af4a257a9564a61725df9c74cb260da544d331";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    glib
    libpng
    zlib
  ];

  cmakeFlags = [
    "-L"
    "-DBUILD_DOC=OFF"
    "-DBUILD_FOR_SSE=ON"
    "-DBUILD_FOR_SSE2=ON"
    "-DLENSTOOL=ON"
    "-DBUILD_STATIC=OFF"
    "-DBUILD_TESTS=OFF"
    "-DBUILD_AUXFUN=ON"
  ];

  meta = with stdenv.lib; {
    description = "A database of photographic lenses & their characteristics";
    homepage = http://lensfun.sourceforge.net/;
    license = licenses.lgpl3; # CC-BY-SA-3.0
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
