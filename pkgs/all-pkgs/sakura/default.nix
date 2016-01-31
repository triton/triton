{ stdenv
, cmake
, fetchurl
, perl

, gdk-pixbuf
, glib
, gtk3
, vte
}:

stdenv.mkDerivation rec {
  name = "sakura-${version}";
  version = "3.3.4";

  src = fetchurl {
    url = "http://launchpad.net/sakura/trunk/${version}/+download/${name}.tar.bz2";
    sha256 = "1fnkrkzf2ysav1ljgi4y4w8kvbwiwgmg1462xhizlla8jqa749r7";
  };

  nativeBuildInputs = [
    cmake
    perl
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    gtk3
    vte
  ];

  meta = with stdenv.lib; {
    description = "A terminal emulator based on GTK and VTE";
    homepage = http://www.pleyades.net/david/projects/sakura;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
