{ stdenv
, fetchurl

, boost
, expat
, zlib
}:

stdenv.mkDerivation rec {
  name = "exempi-2.3.0";

  src = fetchurl {
    url = "https://libopenraw.freedesktop.org/download/${name}.tar.bz2";
    sha256 = "d89aed355e6d38b8525ffeaffe592b362fec3a8306a1d8116625908af8d89949";
  };

  buildInputs = [
    boost
    expat
    zlib
  ];

  configureFlags = [
    "--with-boost=${boost.dev}"
  ];

  meta = with stdenv.lib; {
    description = "Implementation of XMP";
    homepage = http://libopenraw.freedesktop.org/wiki/Exempi/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
