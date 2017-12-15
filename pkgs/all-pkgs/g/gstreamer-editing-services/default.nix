{ stdenv
, fetchurl
, flex
, lib
, meson
, ninja

, glib
, gobject-introspection
, gst-plugins-base
, gstreamer
, libxml2

, channel
}:

let
  inherit (lib)
    boolEn;

  sources = {
    "1.12" = {
      version = "1.12.4";
      sha256 = "bd7eaa2c9572db9e7e535064024b6f69250de864fe8a5d5be86fa8c7edacca0c";
    };
  };

  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "gstreamer-editing-services-${source.version}";

  src = fetchurl rec {
    urls = map (n: "${n}/${name}.tar.xz") [
      "https://gstreamer.freedesktop.org/src/gstreamer-editing-services"
      "mirror://gnome/sources/gstreamer-editing-services/${channel}"
    ];
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    flex
    meson
    ninja
  ];

  buildInputs = [
    glib
    gobject-introspection
    gst-plugins-base
    gstreamer
    libxml2
  ];

  mesonFlags = [
    "-Ddisable_introspection=false"
    "-Ddisable_gtkdoc=true"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Urls = map (n: "${n}.sha256sum") src.urls;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      # Sebastian Dröge
      pgpKeyFingerprint = "7F4B C7CC 3CA0 6F97 336B  BFEB 0668 CC14 86C2 D7B5";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "SDK for making video editors and more";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.lgpl2plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
