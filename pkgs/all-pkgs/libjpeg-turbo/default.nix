{ stdenv
, fetchurl
, yasm
}:

stdenv.mkDerivation rec {
  name = "libjpeg-turbo-1.5.0";

  src = fetchurl {
    url = "mirror://sourceforge/libjpeg-turbo/${name}.tar.gz";
    sha256 = "9f397c31a67d2b00ee37597da25898b03eb282ccd87b135a50a69993b6a2035f";
  };

  nativeBuildInputs = [
    yasm
  ];

  passthru = {
    type = "turbo";
  };

  meta = with stdenv.lib; {
    description = "A faster (using SIMD) libjpeg implementation";
    homepage = http://libjpeg-turbo.virtualgl.org/;
    license = licenses.ijg;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
