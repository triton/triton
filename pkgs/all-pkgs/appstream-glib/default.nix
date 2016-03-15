{ stdenv
#, docbook_xml_dtd_43
#, docbook_xsl
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

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "appstream-glib-0.5.10";

  src = fetchurl {
    url = "https://people.freedesktop.org/~hughsient/appstream-glib/"
        + "releases/${name}.tar.xz";
    sha256 = "00g8i3da0ldy3nq57xnj2cizs73myj5if69a57f52ijasc9vhc9l";
  };

  nativeBuildInputs = [
    #docbook_xml_dtd_43
    #docbook_xsl
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
    (enFlag "introspection" (gobject-introspection != null) null)
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
