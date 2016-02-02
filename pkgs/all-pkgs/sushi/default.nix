{ stdenv
, fetchurl
, gettext
, intltool

, atk
, clutter
, clutter-gst_2
, clutter-gtk
, cogl
, evince
, freetype
, gdk-pixbuf
, gjs
, glib
, gobject-introspection
, gst-plugins-base
, gstreamer
, gtk3
, gtksourceview
, json-glib
, libmusicbrainz5
, pango
, webkitgtk
}:

stdenv.mkDerivation rec {
  name = "sushi-${version}";
  versionMajor = "3.18";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/sushi/${versionMajor}/${name}.tar.xz";
    sha256 = "174fc0jh5q8712flmhggi0dd4vbn13hrr94dyapj7gshx4mzjkbz";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    atk
    clutter
    clutter-gst_2
    clutter-gtk
    cogl
    evince
    freetype
    gdk-pixbuf
    gjs
    glib
    gobject-introspection
    gst-plugins-base
    gstreamer
    gtk3
    gtksourceview
    json-glib
    libmusicbrainz5
    pango
    webkitgtk
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
  ];

  meta = with stdenv.lib; {
    description = "A quick previewer for Nautilus";
    homepage = "http://en.wikipedia.org/wiki/Sushi_(software)";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
