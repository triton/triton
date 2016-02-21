{ stdenv
, cmake
, fetchurl
, ninja

, boost
, ffmpeg
}:

with {
  inherit (stdenv.lib)
    cmFlag;
};

stdenv.mkDerivation rec {
  name = "chromaprint-${version}";
  version = "1.3.1";

  src = fetchurl {
    url = "http://bitbucket.org/acoustid/chromaprint/downloads/${name}.tar.gz";
    sha256 = "10dm9cfqb77g12pyjnqaw80860kzdcvskni02ll7afpywq8s15cg";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    boost
    ffmpeg
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DBUILD_EXAMPLES=ON"
    "-DBUILD_TESTS=OFF"
    (cmFlag "WITH_AVFFT" (ffmpeg != null))
    "-DWITH_FFTW3=OFF"
    "-DWITH_VDSP=OFF"
    "-DWITH_KISSFFT=OFF"
  ];

  meta = with stdenv.lib; {
    description = "AcoustID audio fingerprinting library";
    homepage = "http://acoustid.org/chromaprint";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
