{ stdenv
, fetchurl
, gettext
, intltool
, lib
, meson
, ninja
, vala

, atk
, gdk-pixbuf
, geocode-glib
, glib
, gobject-introspection
, gtk
, libsoup
, libxml2
, pango
, tzdata

, channel
}:

let
  inherit (lib)
    boolTf
    optionals;

  sources = {
    "3.28" = {
      version = "3.28.1";
      sha256 = "157a8388532a751b36befff424b11ed913b2c43689b62cd2060f6847eb730be3";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "libgweather-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libgweather/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    intltool
    meson
    ninja
    vala
  ];

  buildInputs = [
    atk
    gdk-pixbuf
    geocode-glib
    glib
    gobject-introspection
    gtk
    libsoup
    libxml2
    pango
  ];

  postPatch = /* Already handled by setup hooks */ ''
    sed -i meson.build \
      -e '/meson_post_install.py/d'
  '' + /* Remove hardcoded references to build directory */ ''
    sed -i libgweather/gweather-enum-types.h.tmpl \
      -e '/@filename@/d'
  '';

  mesonFlags = optionals (tzdata != null) [
    "-Dzoneinfo_dir=${tzdata}/share/zoneinfo"
  ] ++ [
    #"-Dowm_apikey="
    "-Dglade_catalog=false"
    "-Denable_vala=${boolTf (vala != null)}"
  ];

  setVapidirInstallFlag = false;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/libgweather/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Library to access weather information from online services";
    homepage = https://wiki.gnome.org/Projects/LibGWeather;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
