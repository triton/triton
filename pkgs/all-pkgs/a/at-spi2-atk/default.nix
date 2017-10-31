{ stdenv
, fetchurl
, gettext
, intltool
, lib
#, meson
#, ninja
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
  inherit (lib)
    boolWt
    optionals;

  sources = {
    "2.26" = {
      version = "2.26.1";
      sha256 = "b4f0c27b61dbffba7a5b5ba2ff88c8cee10ff8dac774fa5b79ce906853623b75";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "at-spi2-atk-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/at-spi2-atk/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    #meson
    #ninja
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
    "--${boolWt doCheck}-tests"
  ];

  doCheck = false;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/at-spi2-atk/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
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
