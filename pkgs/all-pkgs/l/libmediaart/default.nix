{ stdenv
, fetchurl

, glib
, gdk-pixbuf
, gobject-introspection
, qt5
, vala
}:

let
  inherit (stdenv.lib)
    enFlag
    optionals;

  versionMajor = "1.9";
  versionMinor = "4";
  version = "${versionMajor}.${versionMinor}";
in

assert gdk-pixbuf != null -> qt5 == null;
assert qt5 != null -> gdk-pixbuf == null;

stdenv.mkDerivation rec {
  name = "libmediaart-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libmediaart/${versionMajor}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "a57be017257e4815389afe4f58fdacb6a50e74fd185452b23a652ee56b04813d";
  };

  buildInputs = [
    gdk-pixbuf
    glib
    gobject-introspection
    qt5
    vala
  ];

  configureFlags = [
    "--disable-installed-tests"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "introspection" (gobject-introspection != null) null)
    (enFlag "vala" (vala != null) null)
    (enFlag "gdkpixbuf" (gdk-pixbuf != null) null)
    (enFlag "qt" (qt5 != null) null)
    "--enable-nemo"
    "--disable-unit-tests"
    "--with-compile-warnings"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/libmediaart/${versionMajor}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
    description = "Manages, extracts and handles media art caches";
    homepage = https://github.com/GNOME/libmediaart;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
