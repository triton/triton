{ stdenv
, fetchurl
, lib

, lcms2
, jasper
}:

let
  version = "0.18.8";
in
stdenv.mkDerivation rec {
  name = "libraw-${version}";

  src = fetchurl {
    url = "https://www.libraw.org/data/LibRaw-${version}.tar.gz";
    multihash = "QmNMs1JrxbwKYpweKc6MtYicyDoETwrxBZo2kTU3xxGRSb";
    sha256 = "56aca4fd97038923d57d2d17d90aa11d827f1f3d3f1d97e9f5a0d52ff87420e2";
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
