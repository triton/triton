{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "expat-2.2.1";

  src = fetchurl {
    url = "mirror://sourceforge/expat/${name}.tar.bz2";
    sha256 = "1868cadae4c82a018e361e2b2091de103cd820aaacb0d6cfa49bd2cd83978885";
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
