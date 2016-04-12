{ stdenv
, fetchurl
, gettext
, intltool
, python

, at-spi2-core
, atk
, dbus
, dbus-glib
, glib

, libxml2
}:

let
  inherit (stdenv.lib)
    optionals
    wtFlag;

  versionMajor = "2.20";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";
  name = "at-spi2-atk-${version}";
  baseUrl = "mirror://gnome/sources/at-spi2-atk/${versionMajor}/${name}";
in

stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    url = "${baseUrl}.tar.xz";
    sha256Url = "${baseUrl}.sha256sum";
    sha256 = "2358a794e918e8f47ce0c7370eee8fc8a6207ff1afe976ec9ff547a03277bf8e";
  };

  nativeBuildInputs = [
    gettext
    intltool
    python
  ];

  buildInputs = [
    at-spi2-core
    atk
    dbus
    dbus-glib
    glib
  ] ++ optionals doCheck [
    libxml2
  ];

  configureFlags = [
    "--enable-schemas-compile"
    "--enable-p2p"
    (wtFlag "tests" doCheck null)
  ];

  doCheck = false;

  meta = with stdenv.lib; {
    description = "Gtk module for bridging AT-SPI to Atk";
    homepage = https://wiki.gnome.org/Accessibility;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
