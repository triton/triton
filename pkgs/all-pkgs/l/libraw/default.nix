{ stdenv
, fetchurl
, lib

, lcms2
, jasper
}:

let
  version = "0.18.3";
in
stdenv.mkDerivation rec {
  name = "libraw-${version}";

  src = fetchurl {
    url = "http://www.libraw.org/data/LibRaw-${version}.tar.gz";
    multihash = "Qmc1Qw5nW69ewRHTTWRtZ7pDwmkUw1F76mHB9pdGpbK2JZ";
    sha256 = "57ba053f075e0b80f747f3102ed985687c16a8754d109e7c4d33633269a36aaa";
  };

  buildInputs = [
    lcms2
    jasper
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

