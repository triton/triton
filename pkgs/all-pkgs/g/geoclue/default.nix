{ stdenv
, fetchurl
, gettext
, intltool

, avahi
, dbus
, glib
, gobject-introspection
, json-glib
, libsoup
, modemmanager
}:

let
  inherit (stdenv.lib)
    enFlag;

  versionMajor = "2.4";
  version = "${versionMajor}.4";
in
stdenv.mkDerivation rec {
  name = "geoclue-${version}";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/geoclue/releases/"
      + "${versionMajor}/${name}.tar.xz";
    sha256 = "9c43fb9d0c12067ea64400500abb0640194947d4c2c55e38545afe5d9c5c315c";
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
    (enFlag "introspection" (gobject-introspection != null) null)
    "--enable-libgeoclue"
    (enFlag "3g-source" (modemmanager != null) null)
    (enFlag "cdma-source" (modemmanager != null) null)
    (enFlag "modem-gps-source" (modemmanager != null) null)
    (enFlag "nmea-source" (avahi != null) null)
    "--enable-backend"
    "--disable-demo-agent"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-debug"
  ];

  meta = with stdenv.lib; {
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
