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

with {
  inherit (stdenv.lib)
    optionals
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "at-spi2-atk-${version}";
  versionMajor = "2.20";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/at-spi2-atk/${versionMajor}/${name}.tar.xz";
    sha256 = "a24b142b6e8f1dd2d57a657447dde3e0ae29df481968c88673a58d4ce44f3ad2";
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
      i686-linux
      ++ x86_64-linux;
  };
}
