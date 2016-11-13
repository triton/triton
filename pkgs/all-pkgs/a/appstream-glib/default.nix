{ stdenv
#, docbook_xml_dtd_43
#, docbook-xsl
, fetchurl
, gettext
, intltool

, fontconfig
, freetype
, gcab
, gdk-pixbuf
, glib
, gobject-introspection
, gtk3
, json-glib
, libarchive
, libsoup
, libyaml
, pango
, sqlite
, util-linux_lib
}:

let
  inherit (stdenv.lib)
    boolEn;
in
stdenv.mkDerivation rec {
  name = "appstream-glib-0.6.5";

  src = fetchurl {
    url = "https://people.freedesktop.org/~hughsient/appstream-glib/"
      + "releases/${name}.tar.xz";
    sha256 = "b6b77540b03ca56d7a8493d5f50ded747b6033e0437d8e4c516b5228e27b2a1a";
  };

  nativeBuildInputs = [
    #docbook_xml_dtd_43
    #docbook-xsl
    gettext
    intltool
  ];

  buildInputs = [
    fontconfig
    freetype
    gcab
    gdk-pixbuf
    glib
    gobject-introspection
    gtk3
    json-glib
    libarchive
    libsoup
    libyaml
    pango
    sqlite
    util-linux_lib
  ];

  configureFlags = [
    "--enable-largefile"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--enable-nls"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-firmware"
    "--enable-fonts"
    "--enable-builder"
    "--disable-rpm"
    # Flag is not a boolean
    #"--disable-alpm"
    "--disable-man"
    "--enable-dep11"
    #"--${boolEn (snowball-stemmer != null)}-stemmer"
  ];

  meta = with stdenv.lib; {
    description = "Objects & helper methods to read & write AppStream metadata";
    homepage = https://github.com/hughsie/appstream-glib;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
