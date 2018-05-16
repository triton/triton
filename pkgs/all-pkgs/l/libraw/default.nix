{ stdenv
, fetchurl
, lib

, lcms2
, libjpeg
, jasper
}:

let
  version = "0.18.11";
in
stdenv.mkDerivation rec {
  name = "libraw-${version}";

  src = fetchurl {
    url = "https://www.libraw.org/data/LibRaw-${version}.tar.gz";
    multihash = "QmY6XydpA8qunrEhSTRdv5kw6WThXofdn8Ep9HTZ5LxfRw";
    sha256 = "7cf724a40a0d8915869498f51062a952167e4f5bae2b6920542c9e0e079a471d";
  };

  buildInputs = [
    lcms2
    libjpeg
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
