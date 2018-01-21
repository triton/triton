{ stdenv
, fetchurl
, lib

, lcms2
, jasper
}:

let
  version = "0.18.7";
in
stdenv.mkDerivation rec {
  name = "libraw-${version}";

  src = fetchurl {
    url = "https://www.libraw.org/data/LibRaw-${version}.tar.gz";
    multihash = "QmXY7C1JRvhLrHcAFHkBxjQvA6PWNmebkYmhLSFxJFXgST";
    sha256 = "87e347c261a8e87935d9a23afd750d27676b99f540e8552314d40db0ea315771";
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
