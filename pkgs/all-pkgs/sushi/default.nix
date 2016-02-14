{ stdenv
, fetchurl
, gettext
, intltool
, makeWrapper

, atk
, clutter
, clutter-gst_2
, clutter-gtk
, cogl
, dconf
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
, xorg
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
    makeWrapper
  ];

  buildInputs = [
    atk
    clutter
    clutter-gst_2
    clutter-gtk
    cogl
    dconf
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
    xorg.libX11
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
  ];

  preFixup = ''
    wrapProgram $out/bin/sushi \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GI_TYPELIB_PATH' : "$GI_TYPELIB_PATH" \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'GST_PLUGIN_SYSTEM_PATH_1_0' : "$GST_PLUGIN_SYSTEM_PATH_1_0" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  meta = with stdenv.lib; {
    description = "A quick previewer for Nautilus";
    homepage = "http://en.wikipedia.org/wiki/Sushi_(software)";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
