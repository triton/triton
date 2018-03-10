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
, util-linux_lib
}:

stdenv.mkDerivation rec {
  name = "appstream-glib-0.7.6";

  src = fetchurl {
    url = "https://people.freedesktop.org/~hughsient/appstream-glib/"
      + "releases/${name}.tar.xz";
    multihash = "QmZkRo11yeyXzYAf2iwpEHF9UtaFSwcGCGjxQNQy5PBKL3";
    sha256 = "b216583a8b9c47f6db52031fbbdfd9005a274c6a0a97c8db8c1d80c890b7d545";
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
    "-Drpm=false"
    "-Dstemmer=false"
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
