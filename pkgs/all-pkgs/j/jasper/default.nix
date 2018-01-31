{ stdenv
, cmake
, fetchurl
, lib
, ninja

, freeglut
, libjpeg
, opengl-dummy
}:

let
  version = "2.0.14";
in
stdenv.mkDerivation rec {
  name = "jasper-${version}";

  src = fetchurl {
    url = "http://www.ece.uvic.ca/~frodo/jasper/software/${name}.tar.gz";
    multihash = "Qme5shSvnKXsNvoACmeqFUUh9UiNCsVy9oGd1JQiHdswFr";
    sha256 = "2a1f61e55afe8b4ce8115e1508c5d7cb314d56dfcc2dd323f90c072f88ccf57b";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    freeglut
    libjpeg
    opengl-dummy
  ];

  cmakeFlags = [
    "-DJAS_ENABLE_SHARED=ON"
    "-DJAS_ENABLE_LIBJPEG=ON"
    "-DJAS_ENABLE_OPENGL=ON"
    "-DJAS_ENABLE_STRICT=OFF"
    "-DJAS_ENABLE_AUTOMATIC_DEPENDENCIES=OFF"
    "-DJAS_LOCAL=OFF"
  ];

  meta = with lib; {
    description = "JPEG2000 Library";
    homepage = https://www.ece.uvic.ca/~frodo/jasper/;
    license = licenses.free;  # JasPer2.0
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
