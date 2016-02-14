{ stdenv
, fetchurl
, gettext

, atk
, clutter
, cogl
, gdk-pixbuf
, glib
, gobject-introspection
, gtk3
, json-glib
, pango
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "clutter-gtk-${version}";
  versionMajor = "1.6";
  versionMinor = "6";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/clutter-gtk/${versionMajor}/${name}.tar.xz";
    sha256 = "0a2a8ci6in82l43zak3zj3cyms23i5rq6lzk1bz013gm023ach4l";
  };

  configureFlags = [
    "--disable-maintainer-flags"
    "--enable-deprecated"
    "--disable-debug"
    "--enable-nls"
    "--enable-rpath"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "introspection" (gobject-introspection != null) null)
  ];

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    atk
    cogl
    clutter
    gdk-pixbuf
    glib
    gobject-introspection
    gtk3
    json-glib
    pango
  ];

  postBuild = "rm -rvf $out/share/gtk-doc";

  meta = with stdenv.lib; {
    description = "Library for embedding a Clutter canvas (stage) in GTK+";
    homepage = http://www.clutter-project.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
