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
    "2.26" = {
      version = "2.26.2";
      sha256 = "c80e0cdf5e3d713400315b63c7deffa561032a6c37289211d8afcfaa267c2615";
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
