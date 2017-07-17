{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "expat-2.2.2";

  src = fetchurl {
    url = "mirror://sourceforge/expat/${name}.tar.bz2";
    sha256 = "4376911fcf81a23ebd821bbabc26fd933f3ac74833f74924342c29aad2c86046";
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
