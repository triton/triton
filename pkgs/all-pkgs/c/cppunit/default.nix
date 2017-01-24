{ stdenv
, fetchurl
}:

stdenv.mkDerivation {
  name = "cppunit-1.13.2";

  src = fetchurl {
    url = http://dev-www.libreoffice.org/src/cppunit-1.13.2.tar.gz;
    multihash = "QmPmS34CqMma8f8RXYMHme2BPJhY7ijinaabKxX7F42syA";
    sha256 = "17s2kzmkw3kfjhpp72rfppyd7syr7bdq5s69syj2nvrlwd3d4irz";
  };

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
