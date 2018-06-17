{ stdenv
, fetchurl
, lib

, lcms2
, libjpeg
, jasper
}:

let
  version = "0.18.12";
in
stdenv.mkDerivation rec {
  name = "libraw-${version}";

  src = fetchurl {
    url = "https://www.libraw.org/data/LibRaw-${version}.tar.gz";
    multihash = "QmYMJHWPp2WoBjACEEEGiMLgGDfu3SW1V8GTxE6huRr42w";
    sha256 = "57754d75a857e16ba1c2a429e4b5b4d79160a59eadaec715351fc9c8448653d4";
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
