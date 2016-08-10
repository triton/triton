{ stdenv
, fetchurl

, lcms2
, jasper
}:

stdenv.mkDerivation rec {
  name = "libraw-${version}";
  version = "0.17.2";

  src = fetchurl {
    url = "http://www.libraw.org/data/LibRaw-${version}.tar.gz";
    multihash = "QmVoz31h5dcgLeYvhdsDQpeAWRwF4HMxrhabEPJzRtr3y9";
    sha256 = "0p6imxpsfn82i0i9w27fnzq6q6gwzvb9f7sygqqakv36fqnc9c4j";
  };

  buildInputs = [
    lcms2
    jasper
  ];

  CXXFLAGS = "-std=c++03";

  meta = with stdenv.lib; {
    description = "Library for reading RAW files obtained from digital photo cameras (CRW/CR2, NEF, RAF, DNG, and others)";
    homepage = http://www.libraw.org/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

