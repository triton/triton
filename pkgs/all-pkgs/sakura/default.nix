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
  version = "3.3.3";

  src = fetchurl {
    url = "http://launchpad.net/sakura/trunk/${version}/+download/${name}.tar.bz2";
    sha256 = "087hqbzdx9y01ksg1mqqd8kc483wfsmfzppjg0ryfkil3l633gd6";
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
