{ stdenv
, cmake
, fetchurl
, lib

, glib
, libpng
, zlib
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (lib)
    boolOn
    elem
    platforms;

  version = "0.3.2";
in
stdenv.mkDerivation rec {
  name = "lensfun-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/lensfun/${version}/${name}.tar.gz";
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
    "-DBUILD_DOC=OFF"
    "-DBUILD_FOR_SSE=${boolOn (elem targetSystem platforms.x86-all)}"
    "-DBUILD_FOR_SSE2=${boolOn (elem targetSystem platforms.x86-all)}"
    "-DLENSTOOL=ON"
    "-DBUILD_STATIC=OFF"
    "-DBUILD_TESTS=OFF"
    "-DBUILD_AUXFUN=ON"
  ];

  meta = with lib; {
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
