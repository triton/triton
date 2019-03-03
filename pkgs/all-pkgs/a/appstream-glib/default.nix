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
  name = "appstream-glib-0.7.15";

  src = fetchurl {
    url = "https://people.freedesktop.org/~hughsient/appstream-glib/"
      + "releases/${name}.tar.xz";
    multihash = "QmXUHVpAM8VdqxiWciLy6Mz4Ytz4dmANNFWunJ48HaxffH";
    sha256 = "7e27947de3742fcc02a96a22fb91e137a49cd55234c407a246476f3624a92a9f";
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

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Urls = map (n: "${n}.sha256sum") src.urls;
      };
      failEarly = true;
    };
  };

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
