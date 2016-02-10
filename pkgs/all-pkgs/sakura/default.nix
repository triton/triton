{ stdenv
, cmake
, fetchurl
, makeWrapper
, perl

, adwaita-icon-theme
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
    makeWrapper
    perl
  ];

  buildInputs = [
    adwaita-icon-theme
    gdk-pixbuf
    glib
    gtk3
    vte
  ];

  preFixup = ''
    wrapProgram $out/bin/sakura \
      --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE" \
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS"
  '';

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
