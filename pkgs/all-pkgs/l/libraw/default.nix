{ stdenv
, fetchurl
, lib

, lcms2
, jasper
}:

let
  version = "0.18.6";
in
stdenv.mkDerivation rec {
  name = "libraw-${version}";

  src = fetchurl {
    url = "https://www.libraw.org/data/LibRaw-${version}.tar.gz";
    multihash = "QmPNa7C3A1LEoBzkjEjynZwr8SYZ8WU4kJWnDUhRV8betv";
    sha256 = "e5b8acca558aa457bc9214802004320c5610d1434c2adb1f3ea367f026afa53b";
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

