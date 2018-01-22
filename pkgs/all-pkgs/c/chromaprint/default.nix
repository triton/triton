{ stdenv
, cmake
, fetchurl
, lib
, ninja

, boost
, fftw_double
}:

let
  inherit (lib)
    boolOn;

  version = "1.4.3";
in
stdenv.mkDerivation rec {
  name = "chromaprint-${version}";

  src = fetchurl {
    url = "https://github.com/acoustid/chromaprint/releases/download/"
      + "v${version}/${name}.tar.gz";
    sha256 = "ea18608b76fb88e0203b7d3e1833fb125ce9bb61efe22c6e169a50c52c457f82";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    boost
    fftw_double
  ];

  cmakeFlags = [
    "-DBUILD_EXAMPLES=OFF"
    "-DBUILD_SHARED_LIBS=ON"
    "-DBUILD_TESTS=OFF"
    "-DWITH_AVFFT=OFF"  # FFmpeg is required for fpcalc, but is a recursive dep
    "-DWITH_FFTW3=${boolOn (fftw_double != null)}"
    "-DWITH_VDSP=OFF"
    "-DWITH_KISSFFT=OFF"
  ];

  meta = with lib; {
    description = "AcoustID audio fingerprinting library";
    homepage = http://acoustid.org/chromaprint;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
