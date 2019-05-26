{ stdenv
, fetchTritonPatch
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "cppunit-1.14.0";

  src = fetchurl {
    url = "https://dev-www.libreoffice.org/src/${name}.tar.gz";
    multihash = "QmUdPCbTGq4fuyXUV7MoMBPQuW2shm4W9cWvMxfJe47koq";
    sha256 = "3d569869d27b48860210c758c4f313082103a5e58219a7669b52bfd29d674780";
  };

  patches = [
    # Fix compat with GCC 9.1, remove for 1.15+
    (fetchTritonPatch {
      rev = "e8619d4113073eb9ecf0a4adac7e65243d2a86dd";
      file = "c/cppunit/cppunit-fix.gcc.9.1.patch";
      sha256 = "a87312d818ba28e6a9a0d5294ebafde7df9de5096276b32905e9404700dd1020";
    })
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    homepage = "http://sourceforge.net/apps/mediawiki/cppunit/";
    description = "C++ unit testing framework";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
