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
, inputproto
, kbproto
, libsm
, libice
, libx11
, libxi
, xextproto
, xorg
, xproto

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt;

  sources = {
    "2.26" = {
      version = "2.26.0";
      sha256 = "511568a65fda11fdd5ba5d4adfd48d5d76810d0e6ba4f7460f1b2ec0dbbbc337";
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
    inputproto
    kbproto
    xproto
    libsm
    libx11
    libxi
    xorg.libXtst
    xextproto
  ];

  postPatch = /* Meson file missing in release tarball */ ''
    [ ! -f po/meson.build ]
    cat > po/meson.build <<EOF
    i18n = import('i18n')
    i18n.gettext('at-spi2-core', preset: 'glib')
    EOF
  '' + /* Remove hardcoded references to the build driectory */ ''
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
