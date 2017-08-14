{ stdenv
, fetchurl
, gettext
, intltool
, lib

, glib
, gobject-introspection
, gvfs
, json-glib
, libsoup
}:

let
  inherit (lib)
    boolEn;

  channel = "3.24";
  version = "${channel}.0";
in
stdenv.mkDerivation rec {
  name = "geocode-glib-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/geocode-glib/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "19c1fef4fd89eb4bfe6decca45ac45a2eca9bb7933be560ce6c172194840c35e";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    glib
    gobject-introspection
    gvfs
    json-glib
    libsoup
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-rpath"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--enable-compile-warnings"
    "--disable-Werror"
    "--disable-always-build-tests"
    "--disable-installed-tests"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/geocode-glib/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "GLib geocoding library uses the Yahoo! Place Finder service";
    homepage = https://git.gnome.org/browse/geocode-glib;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };

}
