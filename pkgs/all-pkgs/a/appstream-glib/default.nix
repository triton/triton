{ stdenv
, docbook_xml_dtd_42
, docbook-xsl
, fetchurl
, gettext
, gperf
, intltool
, lib
, libxslt
, meson
, ninja

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

stdenv.mkDerivation rec {
  name = "appstream-glib-0.7.2";

  src = fetchurl {
    url = "https://people.freedesktop.org/~hughsient/appstream-glib/"
      + "releases/${name}.tar.xz";
    multihash = "QmewNZ94pNeVyKyJk8put6PvH1a1hbuAtz4CHF7fXDdTjq";
    sha256 = "c3b95171db6f61e9273c0e1e9341f19e487e20d49c466f56cd87f18c1859b77f";
  };

  nativeBuildInputs = [
    docbook_xml_dtd_42
    docbook-xsl
    gettext
    gperf
    libxslt
    meson
    ninja
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
    util-linux_lib
  ];

  mesonFlags = [
    "-Denable-rpm=false"
    "-Denable-stemmer=false"
  ];

  meta = with lib; {
    description = "Objects & helper methods to read & write AppStream metadata";
    homepage = https://github.com/hughsie/appstream-glib;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
