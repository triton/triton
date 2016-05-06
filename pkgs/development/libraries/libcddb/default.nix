{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libcddb-1.3.2";
  
  src = fetchurl {
    url = "mirror://sourceforge/libcddb/${name}.tar.bz2";
    sha256 = "0fr21a7vprdyy1bq6s99m0x420c9jm5fipsd63pqv8qyfkhhxkim";
  };

  meta = with stdenv.lib; {
    description = "C library to access data on a CDDB server (freedb.org)";
    homepage = http://libcddb.sourceforge.net/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
