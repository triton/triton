{ stdenv, fetchurl, intltool, gtk2, gtk3, gnome3, librsvg, pango, atk, cairo, gdk_pixbuf, glib }:

stdenv.mkDerivation rec {
  inherit (import ./src.nix fetchurl) name src;
  
  nativeBuildInputs = [ intltool ];
  buildInputs = [ gtk2 gtk3 librsvg pango atk cairo gdk_pixbuf glib gnome3.defaultIconTheme ];

  meta = with stdenv.lib; {
    platforms = platforms.linux;
    maintainers = gnome3.maintainers;
  };
}
