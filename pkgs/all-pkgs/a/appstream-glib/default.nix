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

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpKeyFingerprint = "C12B 8963 4A18 D2C3 F8B3  6C4C F09D 2D23 7A47 1537";
      failEarly = true;
    };
  };

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
