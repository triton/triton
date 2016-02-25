{ stdenv
, fetchurl
, texinfo
}:

stdenv.mkDerivation rec {
  name = "lzip-1.16";

  src = fetchurl {
    url = "mirror://savannah/lzip/${name}.tar.gz";
    sha256 = "0l9724rw1l3hg2ldr3n7ihqich4m9nc6y7l302bvdj4jmxdw530j";
  };

  nativeBuildInputs = [
    texinfo
  ];

  configureFlags = [
    "CPPFLAGS=-DNDEBUG"
    "CFLAGS=-O3"
    "CXXFLAGS=-O3"
  ];

  meta = with stdenv.lib; {
    homepage = "http://www.nongnu.org/lzip/lzip.html";
    description = "a lossless data compressor based on the LZMA algorithm";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
