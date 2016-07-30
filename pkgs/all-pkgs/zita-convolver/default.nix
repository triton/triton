{ stdenv
, fetchurl

, fftw_single
}:

stdenv.mkDerivation rec {
  name = "zita-convolver-3.1.0";

  src = fetchurl {
    url = "http://kokkinizita.linuxaudio.org/linuxaudio/downloads/"
      + "${name}.tar.bz2";
    sha256 = "bf7e93b582168b78d40666974460ad8142c2fa3c3412e327e4ab960b3fb31993";
  };

  buildInputs = [
    fftw_single
  ];

  postUnpack = ''
    sourceRoot="$sourceRoot/libs"
  '';

  postPatch = ''
    sed -i Makefile \
      -e 's/ldconfig//'
  '';

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$out"
    )
  '';

  meta = with stdenv.lib; {
    description = "Convolution library by Fons Adriaensen";
    homepage = "http://kokkinizita.linuxaudio.org/linuxaudio/";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
