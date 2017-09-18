{ stdenv
, fetchurl
, lib

, lcms2
, jasper
}:

let
  version = "0.18.4";
in
stdenv.mkDerivation rec {
  name = "libraw-${version}";

  src = fetchurl {
    url = "https://www.libraw.org/data/LibRaw-${version}.tar.gz";
    multihash = "QmaXP6gqQqPbZCkKzd7EFMFodAN3fg5rFijnbVDjE1X3qV";
    sha256 = "eaf4931b46e65861e88bbe704ccf370381e94d63e9a898b889ded4e0cb3b0c97";
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

