{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja

, freeglut
, libjpeg
, opengl-dummy
}:

let
  version = "2.0.16";
in
stdenv.mkDerivation rec {
  name = "jasper-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "mdadams";
    repo = "jasper";
    rev = "version-${version}";
    sha256 = "e76cac931c114d495c0ee737a75e0f0055757ea5d71550ad97136b557d62e76d";
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
