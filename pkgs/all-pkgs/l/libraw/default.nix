{ stdenv
, fetchurl

, lcms2
, jasper
}:

let
  version = "0.18.2";
in
stdenv.mkDerivation rec {
  name = "libraw-${version}";

  src = fetchurl {
    url = "http://www.libraw.org/data/LibRaw-${version}.tar.gz";
    multihash = "QmRH35WdypzX7dzUodCQsC2LsNZcY48n3KdMarvmL1GXrS";
    sha256 = "ce366bb38c1144130737eb16e919038937b4dc1ab165179a225d5e847af2abc6";
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

