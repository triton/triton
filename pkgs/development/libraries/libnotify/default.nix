{ stdenv, fetchurl
, glib, gdk-pixbuf, gobject-introspection, gtk_3 }:

stdenv.mkDerivation rec {
  ver_maj = "0.7";
  ver_min = "7";
  name = "libnotify-${ver_maj}.${ver_min}";

  src = fetchurl {
    url = "mirror://gnome/sources/libnotify/${ver_maj}/${name}.tar.xz";
    sha256 = "9cb4ce315b2655860c524d46b56010874214ec27e854086c1a1d0260137efc04";
  };

  buildInputs = [ glib gdk-pixbuf gobject-introspection gtk_3 ];

  meta = {
    homepage = http://galago-project.org/; # very obsolete but found no better
    description = "A library that sends desktop notifications to a notification daemon";
  };
}
