{ stdenv
, fetchurl
, lib
, meson
, ninja

, ffmpeg
, glib
, gst-plugins-base
, gstreamer
, orc
, zlib

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt;

  sources = {
    "1.12" = {
      version = "1.12.3";
      sha256 = "015ef8cab6f7fb87c8fb42642486423eff3b6e6a6bccdcd6a189f436a3619650";
    };
  };

  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "gst-libav-${source.version}";

  src = fetchurl rec {
    urls = map (n: "${n}/${name}.tar.xz") [
      "https://gstreamer.freedesktop.org/src/gst-libav"
      "mirror://gnome/sources/gst-libav/${channel}"
    ];
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  buildInputs = [
    ffmpeg
    glib
    gst-plugins-base
    gstreamer
    orc
    zlib
  ];

  NIX_CFLAGS_COMPILE = [
    # Gstreamer lags behind FFmpeg and may use functions marked as deprecated.
    "-Wno-deprecated-declarations"
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
    description = "FFmpeg based gstreamer plugin";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
