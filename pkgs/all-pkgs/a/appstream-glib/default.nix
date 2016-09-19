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
  name = "appstream-glib-0.6.3";

  src = fetchurl {
    url = "https://people.freedesktop.org/~hughsient/appstream-glib/"
      + "releases/${name}.tar.xz";
    sha256 = "3ec355c950b86cd792b6e396a5a4a72487999e300fcacf7466a663974ec4ad24";
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
