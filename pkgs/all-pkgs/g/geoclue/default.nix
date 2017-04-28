{ stdenv
, fetchurl
, gettext
, intltool
, lib

, avahi
, dbus
, glib
, gobject-introspection
, json-glib
, libsoup
, modemmanager
}:

let
  inherit (lib)
    boolEn;

  versionMajor = "2.4";
  version = "${versionMajor}.6";
in
stdenv.mkDerivation rec {
  name = "geoclue-${version}";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/geoclue/releases/"
      + "${versionMajor}/${name}.tar.xz";
    sha256 = "c57df7455c9b4b2f43b0f5d9be14d52f5ff9897236df768f6ca9044b79b6d3b6";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    avahi
    dbus
    glib
    gobject-introspection
    json-glib
    libsoup
    modemmanager
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-systemdsystemunitdir=$out/etc/systemd/system"
    )
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--enable-libgeoclue"
    "--${boolEn (modemmanager != null)}-3g-source"
    "--${boolEn (modemmanager != null)}-cdma-source"
    "--${boolEn (modemmanager != null)}-modem-gps-source"
    "--${boolEn (avahi != null)}-nmea-source"
    "--enable-backend"
    "--disable-demo-agent"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-debug"
  ];

  meta = with lib; {
    description = "Geolocation framework and some data providers";
    homepage = https://www.freedesktop.org/software/geoclue/;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
