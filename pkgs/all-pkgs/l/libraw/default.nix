{ stdenv
, fetchurl
, lib

, lcms2
, libjpeg
, jasper
}:

let
  version = "0.19.0";
in
stdenv.mkDerivation rec {
  name = "libraw-${version}";

  src = fetchurl {
    url = "https://www.libraw.org/data/LibRaw-${version}.tar.gz";
    multihash = "QmRVsUUTDEy55LaiwBWv8niZ1xRVdfnVEMdEsWM3Je8pwb";
    sha256 = "e83f51e83b19f9ba6b8bd144475fc12edf2d7b3b930d8d280bdebd8a8f3ed259";
  };

  buildInputs = [
    lcms2
    libjpeg
    jasper
  ];

  configureFlags = [
    "--enable-openmp"
    "--enable-jpeg"
    "--enable-jasper"
    "--enable-lcms"
    "--disable-examples"
  ];

  meta = with lib; {
    description = "Library for reading RAW files obtained from digital photo "
      + "cameras (CRW/CR2, NEF, RAF, DNG, and others)";
    homepage = http://www.libraw.org/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
