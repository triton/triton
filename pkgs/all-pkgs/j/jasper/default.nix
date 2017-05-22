{ stdenv
, cmake
, fetchpatch
, fetchTritonPatch
, fetchFromGitHub
, lib
, ninja

, freeglut
, libjpeg
, mesa
}:

let
  inherit (lib)
    boolOn;

  version = "2.0.13";
in
stdenv.mkDerivation rec {
  name = "jasper-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "mdadams";
    repo = "jasper";
    rev = "version-${version}";
    sha256 = "36bd07db8840ac3cb2c72ea3a3aea20db7b2e81e51f5016b6ad48f6974e82f98";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    freeglut
    libjpeg
    mesa
  ];

  cmakeFlags = [
    "-DJAS_ENABLE_SHARED=ON"
    "-DJAS_ENABLE_LIBJPEG=${boolOn (libjpeg != null)}"
    "-DJAS_ENABLE_OPENGL=${boolOn (freeglut != null && mesa != null)}"
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
