{ stdenv
#, docbook_xml_dtd_43
#, docbook-xsl
, fetchurl
, gettext
, gperf
, intltool
, lib

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
  name = "appstream-glib-0.6.13";

  src = fetchurl {
    url = "https://people.freedesktop.org/~hughsient/appstream-glib/"
      + "releases/${name}.tar.xz";
    multihash = "QmW5bn9N8T9y3gQNC3axVVHdQA9SpEX66rvKqj5tx9H9JL";
    sha256 = "1a3734b2cdaab55ad63c6e3ee31026fdceb122cecae39f9f7126a0305e8836bf";
  };

  nativeBuildInputs = [
    #docbook_xml_dtd_43
    #docbook-xsl
    gettext
    gperf
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
    "--enable-rpath"
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

  meta = with lib; {
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
