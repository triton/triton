{ stdenv
, fetchurl
, gettext
, lib
, meson
, ninja

, dbus
, dbus-glib
, glib
, gobject-introspection
, libsm
, libice
, libx11
, libxi
, libxtst
, xorg
, xorgproto

, channel
}:

let
  sources = {
    "2.30" = {
      version = "2.30.0";
      sha256 = "0175f5393d19da51f4c11462cba4ba6ef3fa042abf1611a70bdfed586b7bfb2b";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "at-spi2-core-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/at-spi2-core/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    meson
    ninja
  ];

  buildInputs = [
    dbus
    dbus-glib
    glib
    gobject-introspection
    libsm
    libx11
    libxi
    libxtst
    xorgproto
  ];

  mesonFlags = [
    #"-Ddbus_services_dir"
    "-Ddbus_daemon=/run/current-system/sw/bin/dbus-daemon"
    #"-Dsystemd_user_dir="
    "-Denable-introspection=yes"
    "-Denable-x11=yes"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Url = "https://download.gnome.org/sources/at-spi2-core/"
        + "${channel}/${name}.sha256sum";
      };
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "D-Bus accessibility specifications and registration daemon";
    homepage = https://wiki.gnome.org/Accessibility;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
