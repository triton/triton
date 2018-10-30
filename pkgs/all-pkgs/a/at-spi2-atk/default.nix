{ stdenv
, fetchurl
, gettext
, lib
, meson
, ninja

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
    "2.30" = {
      version = "2.30.0";
      sha256 = "e2e1571004ea7b105c969473ce455a95be4038fb2541471714aeb33a26da8a9a";
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
    meson
    ninja
  ];

  buildInputs = [
    at-spi2-core
    atk
    dbus
    dbus-glib
    glib
    libxml2  # FIXME: Only needed for tests
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Url = "https://download.gnome.org/sources/at-spi2-atk/${channel}/"
          + "${name}.sha256sum";
      };
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
