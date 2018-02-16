{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "cppunit-1.14.0";

  src = fetchurl {
    url = "https://dev-www.libreoffice.org/src/${name}.tar.gz";
    multihash = "QmUdPCbTGq4fuyXUV7MoMBPQuW2shm4W9cWvMxfJe47koq";
    sha256 = "3d569869d27b48860210c758c4f313082103a5e58219a7669b52bfd29d674780";
  };

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
