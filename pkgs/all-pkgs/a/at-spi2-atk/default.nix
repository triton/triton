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

, channel
}:

let
  inherit (stdenv.lib)
    optionals
    wtFlag;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "at-spi2-atk-${source.version}";

  src = fetchurl {
    url = "mirror://gnome-insecure/sources/at-spi2-atk/${channel}/${name}.tar.xz";
    sha256Url = "mirror://gnome-secure/sources/at-spi2-atk/${channel}/"
      + "${name}.sha256sum";
    inherit (source) sha256;
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
