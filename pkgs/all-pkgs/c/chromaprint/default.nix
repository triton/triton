{ stdenv
, cmake
, fetchurl
, lib
, ninja

, boost
, fftw_double
}:

let
  inherit (stdenv.lib)
    boolOn;

  version = "1.3.2";
in
stdenv.mkDerivation rec {
  name = "chromaprint-${version}";

  src = fetchurl {
    url = [
      "https://bitbucket.org/acoustid/chromaprint/downloads/${name}.tar.gz"
      "mirror://gentoo/distfiles/${name}.tar.gz"
    ];
    sha256 = "c3af900d8e7a42afd74315b51b79ebd2e43bc66630b4ba585a54bf3160439652";
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
