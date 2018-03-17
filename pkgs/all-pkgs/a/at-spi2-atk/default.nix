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
    "2.26" = {
      version = "2.26.2";
      sha256 = "61891f0abae1689f6617a963105a3f1dcdab5970c4a36ded9c79a7a544b16a6e";
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

  mesonFlags = [
    "-Ddisable_p2p=false"
  ];

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
