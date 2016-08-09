{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "expat-2.2.0";

  src = fetchurl {
    url = "mirror://sourceforge/expat/${name}.tar.bz2";
    multihash = "QmXyog231KWB6xwMbPjpv51akeJZj1jHsdkVrWNkMxzVgX";
    sha256 = "d9e50ff2d19b3538bd2127902a89987474e1a4db8e43a66a4d1a712ab9a504ff";
  };

  meta = with stdenv.lib; {
    description = "A stream-oriented XML parser library written in C";
    homepage = http://www.libexpat.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
