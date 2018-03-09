{ stdenv
, fetchurl
, gettext
, lib
, meson
, ninja
, python3

, aalib
, bzip2
, cairo
, flac
, gdk-pixbuf
, glib
, gst-plugins-base
, gstreamer
, libcaca
, libgudev
, jack2_lib
, libjpeg
, libpng
, pulseaudio_lib
, libshout
, libsoup
, v4l_lib
, libvpx
, libx11
, libxext
, orc
, speex
, taglib
, wavpack
, xorg
, xorgproto
, zlib

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt;

  sources = {
    "1.12" = {
      version = "1.12.4";
      sha256 = "649f49bec60892d47ee6731b92266974c723554da1c6649f21296097715eb957";
    };
  };

  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "gst-plugins-good-${source.version}";

  src = fetchurl rec {
    urls = map (n: "${n}/${name}.tar.xz") [
      "https://gstreamer.freedesktop.org/src/gst-plugins-good"
      "mirror://gnome/sources/gst-plugins-good/${channel}"
    ];
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    meson
    ninja
  ];

  buildInputs = [
    aalib
    bzip2
    cairo
    flac
    gdk-pixbuf
    glib
    gst-plugins-base
    gstreamer
    libcaca
    libgudev
    jack2_lib
    libjpeg
    libpng
    pulseaudio_lib
    libshout
    libsoup
    v4l_lib
    libvpx
    libx11
    libxext
    orc
    speex
    taglib
    wavpack
    xorgproto
    zlib
  ];

  mesonFlags = [
    "-Dv4l2-probe=${if v4l_lib != null then "true" else "false"}"
    "-Dwith-libv4l2=${if v4l_lib != null then "true" else "false"}"
    "-Duse_orc=yes"
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
    description = "Basepack of plugins for GStreamer";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
