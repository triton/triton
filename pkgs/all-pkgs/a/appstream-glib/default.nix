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

let
  inherit (stdenv.lib)
    boolEn;
in
stdenv.mkDerivation rec {
  name = "appstream-glib-0.7.0";

  src = fetchurl {
    url = "https://people.freedesktop.org/~hughsient/appstream-glib/"
      + "releases/${name}.tar.xz";
    multihash = "Qmb4Z1eSy4UpvXTHfn3KpVrLh6P4Kf1nqb65NgwCF6n2cf";
    sha256 = "08c3655a54af958263800f1f4a5ef4e6a1da4e6db2432006b1ea07b94f4bc106";
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
