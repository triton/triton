{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "expat-2.1.1";

  src = fetchurl {
    url = "mirror://sourceforge/expat/${name}.tar.bz2";
    sha256 = "0ryyjgvy7jq0qb7a9mhc1giy3bzn56aiwrs8dpydqngplbjq9xdg";
  };

  meta = with stdenv.lib; {
    homepage = http://www.libexpat.org/;
    description = "A stream-oriented XML parser library written in C";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
