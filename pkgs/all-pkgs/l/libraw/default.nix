{ stdenv
, fetchurl

, lcms2
, jasper
}:

let
  version = "0.18.0";
in
stdenv.mkDerivation rec {
  name = "libraw-${version}";

  src = fetchurl {
    url = "http://www.libraw.org/data/LibRaw-${version}.tar.gz";
    multihash = "QmbFXNyPCWQh5SU83rabYZGiQHMQN47ChSBgzeURDj41ov";
    sha256 = "d56a0c9a0e6d1b8c8c5585346acf2cfb0554eee0f0948da66f580cd65c8c5c9b";
  };

  buildInputs = [
    lcms2
    jasper
  ];

  meta = with stdenv.lib; {
    description = "Library for reading RAW files obtained from digital photo cameras (CRW/CR2, NEF, RAF, DNG, and others)";
    homepage = http://www.libraw.org/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

