{ fetchurl, stdenv, glib, pkgconfig, udev, libgudev }:

stdenv.mkDerivation rec {
  name = "libwacom-0.17";

  src = fetchurl {
    url = "mirror://sourceforge/linuxwacom/libwacom/${name}.tar.bz2";
    sha256 = "09bmsn3w6p488dd835zbdgj78dga14dh8fw9fi3lqfzvyxkpjlc9";
  };

  buildInputs = [ glib pkgconfig udev libgudev ];

  meta = with stdenv.lib; {
    platforms = platforms.linux;
    homepage = http://sourceforge.net/projects/linuxwacom/;
    description = "libraries, configuration, and diagnostic tools for Wacom tablets running under Linux";
  };

}
