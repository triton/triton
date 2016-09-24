{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "giflib-5.1.4";

  src = fetchurl {
    url = "mirror://sourceforge/giflib/${name}.tar.bz2";
    sha256 = "df27ec3ff24671f80b29e6ab1c4971059c14ac3db95406884fc26574631ba8d5";
  };
  
  meta = with stdenv.lib; {
    description = "A library for reading and writing gif images";
    license = licenses.mit;
    maintainers = with stdenv.lib.maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
