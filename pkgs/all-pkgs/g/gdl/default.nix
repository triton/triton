{ stdenv
, fetchurl
, gettext
, intltool
, lib

, atk
, gdk-pixbuf
, glib
, gobject-introspection
, gtk
, libxml2
, pango
}:

let
  channel = "3.26";
  version = "${channel}.0";
in
stdenv.mkDerivation rec {
  name = "gdl-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gdl/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "f3ad03f9a34f751f52464e22d962c0dec8ff867b7b7b37fe24907f3dcd54c079";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    atk
    gdk-pixbuf
    glib
    gobject-introspection
    gtk
    libxml2
    pango
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--disable-gtk-doc"
    "--disable-gtk-doc"
    "--disable-gtk-doc"
    "--enable-introspection"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gdl/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "GNOME Docking Library";
    homepage = http://www.gnome.org/;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
