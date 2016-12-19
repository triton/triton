{ stdenv
, fetchurl
, lib
}:

let
  version = "1.3.2";
in
stdenv.mkDerivation rec {
  name = "libcddb-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/libcddb/libcddb/${version}/${name}.tar.bz2";
    sha256 = "0fr21a7vprdyy1bq6s99m0x420c9jm5fipsd63pqv8qyfkhhxkim";
  };

  configureFlags = [
    "--without-cdio"
    "--with-iconv"
  ];

  meta = with lib; {
    description = "C library to access data on a CDDB server (freedb.org)";
    homepage = http://libcddb.sourceforge.net/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
