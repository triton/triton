{ stdenv
, fetchurl
, lib

, lcms2
, jasper
}:

let
  version = "0.18.5";
in
stdenv.mkDerivation rec {
  name = "libraw-${version}";

  src = fetchurl {
    url = "https://www.libraw.org/data/LibRaw-${version}.tar.gz";
    multihash = "QmcPDdXRYh5YSgaZvaExrTBVEDxqvcam39uipbPyTFnVLJ";
    sha256 = "fa2a7d14d9dfaf6b368f958a76d79266b3f58c2bc367bebab56e11baa94da178";
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

