{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "jemalloc-4.1.0";

  src = fetchurl {
    url = "http://www.canonware.com/download/jemalloc/${name}.tar.bz2";
    sha256 = "13pc6gcs5d6ws63jv83vslrb1vlqdnf1dg43awkb9bbj9xqnvl7s";
  };

  meta = with stdenv.lib; {
    homepage = http://www.canonware.com/jemalloc/index.html;
    description = "General purpose malloc(3) implementation";
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
