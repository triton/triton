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
  inherit (lib)
    boolEn
    boolWt;

  sources = {
    "2.28" = {
      version = "2.28.0";
      sha256 = "42a2487ab11ce43c288e73b2668ef8b1ab40a0e2b4f94e80fca04ad27b6f1c87";
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

  postPatch = /* Remove hardcoded references to the build driectory */ ''
    sed -i atspi/atspi-enum-types.h.template \
      -e '/@filename@/d'
  '';

  mesonFlags = [
    #"-Ddbus_services_dir"
    "-Ddbus_daemon=/run/current-system/sw/bin/dbus-daemon"
    #"-Dsystemd_user_dir"
    "-Denable_docs=false"
    "-Denable-introspection=yes"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/at-spi2-core/"
        + "${channel}/${name}.sha256sum";
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
