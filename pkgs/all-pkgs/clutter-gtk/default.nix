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

let
  inherit (stdenv.lib)
    enFlag;
in

stdenv.mkDerivation rec {
  name = "clutter-gtk-${version}";
  versionMajor = "1.8";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/clutter-gtk/${versionMajor}/${name}.tar.xz";
    sha256 = "742ef9d68ece36cbb1b2e1a4a6fbdad932f6645360be7e6de75abbb140dfbf1d";
  };

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

  configureFlags = [
    "--disable-deprecated"
    "--disable-debug"
    "--disable-maintainer-flags"
    "--enable-nls"
    "--enable-rpath"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "introspection" (gobject-introspection != null) null)
  ];

  postBuild = "rm -frv $out/share/gtk-doc";

  meta = with stdenv.lib; {
    description = "Library for embedding a Clutter canvas (stage) in GTK+";
    homepage = http://www.clutter-project.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
