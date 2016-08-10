{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libebml-1.3.4";

  src = fetchurl {
    url = "https://dl.matroska.org/downloads/libebml/${name}.tar.bz2";
    sha256 = "c50d3ecf133742c6549c0669c3873f968e11a365a5ba17b2f4dc339bbe51f387";
  };

  meta = with stdenv.lib; {
    description = "Extensible Binary Meta Language library";
    license = licenses.lgpl21;
    homepage = http://dl.matroska.org/downloads/libebml/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
