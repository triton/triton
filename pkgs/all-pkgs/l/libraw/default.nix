{ stdenv
, fetchurl
, lib

, lcms2
, jasper
}:

let
  version = "0.18.9";
in
stdenv.mkDerivation rec {
  name = "libraw-${version}";

  src = fetchurl {
    url = "https://www.libraw.org/data/LibRaw-${version}.tar.gz";
    multihash = "QmYfDcuqTFijZSUqJoA38n2T9XbRMow8B6conjhMLag79U";
    sha256 = "d2ef177032e6d804fc512b206d02c393fca26be43ecd136cc26926407273b24e";
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
