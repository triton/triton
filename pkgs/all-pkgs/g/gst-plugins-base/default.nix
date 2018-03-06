{ stdenv
, fetchurl
, gettext
, lib
, meson
, ninja
, python3

, alsa-lib
, cdparanoia
, glib
, gobject-introspection
, gstreamer
, iso-codes
, libogg
, libtheora
, libvisual
, libvorbis
, libx11
, libxext
, libxv
, opus
, orc
, pango
, xorgproto
, zlib

, channel
}:

let
  inherit (lib)
    boolEn;

  sources = {
    "1.12" = {
      version = "1.12.4";
      sha256 = "4c306b03df0212f1b8903784e29bb3493319ba19ebebf13b0c56a17870292282";
    };
  };

  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "gst-plugins-base-${source.version}";

  src = fetchurl rec {
    urls = map (n: "${n}/${name}.tar.xz") [
      "https://gstreamer.freedesktop.org/src/gst-plugins-base"
      "mirror://gnome/sources/gst-plugins-base/${channel}"
    ];
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    meson
    ninja
    python3
  ];

  buildInputs = [
    alsa-lib
    cdparanoia
    glib
    gobject-introspection
    gstreamer
    iso-codes
    libogg
    libtheora
    libvisual
    libvorbis
    libx11
    libxext
    libxv
    opus
    orc
    pango
    xorgproto
    zlib
  ];

  postPatch = ''
    patchShebangs gst-libs/gst/tag/tag_mkenum.py
    patchShebangs gst-libs/gst/video/video_mkenum.py
    patchShebangs gst-libs/gst/audio/audio_mkenum.py
    patchShebangs gst-libs/gst/rtp/rtp_mkenum.py
    patchShebangs gst-libs/gst/rtsp/rtsp_mkenum.py
    patchShebangs gst-libs/gst/pbutils/pbutils_mkenum.py
    patchShebangs gst-libs/gst/app/app_mkenum.py
  '';

  mesonFlags = [
    "-Daudioresample_format=float"
    "-Ddisable_examples=true"
    "-Duse_orc=yes"
    "-Ddisable_introspection=false"
    "-Ddisable_gtkdoc=false"
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
    description = "Basepack of plugins for gstreamer";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
