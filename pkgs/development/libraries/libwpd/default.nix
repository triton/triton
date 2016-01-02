{ stdenv, fetchurl, zlib, pkgconfig, glib, libgsf, libxml2, librevenge }:

stdenv.mkDerivation rec {
  name = "libwpd-0.10.1";
  
  src = fetchurl {
    url = "mirror://sourceforge/libwpd/${name}.tar.xz";
    sha256 = "1xl457xl0zddb2dy3zp35lra67kp271bai45vkpdkybhqw5l3lq9";
  };
  
  buildInputs = [ glib libgsf libxml2 zlib librevenge ];

  nativeBuildInputs = [ pkgconfig ];

  meta = with stdenv.lib; {
    description = "A library for importing and exporting WordPerfect documents";
    homepage = http://libwpd.sourceforge.net/;
    license = licenses.lgpl21;
  };
}
