{ stdenv
, fetchurl
, lib
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
, orc
, speex
, taglib
, wavpack
, xorg
, zlib

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt;

  sources = {
    "1.12" = {
      version = "1.12.2";
      sha256 = "5591ee7208ab30289a30658a82b76bf87169c927572d9b794f3a41ed48e1ee96";
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
    python3
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
    orc
    speex
    taglib
    wavpack
    zlib
    xorg.libX11
    xorg.libXext
    xorg.xextproto
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-rpath"
    "--disable-fatal-warnings"
    "--disable-extra-checks"
    "--disable-debug"
    "--disable-profiling"
    "--disable-valgrind"
    "--disable-gcov"
    "--disable-examples"
    "--enable-external"
    "--enable-experimental"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-gobject-cast-checks"
    "--disable-glib-asserts"
    "--${boolEn (orc != null)}-orc"
    "--enable-Bsymbolic"
    "--disable-static-plugins"
    # Internal plugins
    "--enable-alpha"
    "--enable-apetag"
    "--enable-audiofx"
    "--enable-audioparsers"
    "--enable-auparse"
    "--enable-autodetect"
    "--enable-avi"
    "--enable-cutter"
    "--disable-debugutils"
    "--enable-deinterlace"
    "--enable-dtmf"
    "--enable-effectv"
    "--enable-equalizer"
    "--enable-flv"
    "--enable-flx"
    "--enable-goom"
    "--enable-goom2k1"
    "--enable-icydemux"
    "--enable-id3demux"
    "--enable-imagefreeze"
    "--enable-interleave"
    "--enable-isomp4"
    "--enable-law"
    "--enable-level"
    "--enable-matroska"
    "--enable-monoscope"
    "--enable-multifile"
    "--enable-multipart"
    "--enable-replaygain"
    "--enable-rtp"
    "--enable-rtpmanager"
    "--enable-rtsp"
    "--enable-shapewipe"
    "--enable-smpte"
    "--enable-spectrum"
    "--enable-udp"
    "--enable-videobox"
    "--enable-videocrop"
    "--enable-videofilter"
    "--enable-videomixer"
    "--enable-wavenc"
    "--enable-wavparse"
    "--enable-y4m"
    # External plugins
    "--disable-directsound"
    "--enable-waveform"
    "--disable-oss"
    "--disable-oss4"
    "--disable-sunaudio"
    "--disable-osx_audio"
    "--disable-osx_video"
    "--${boolEn (v4l_lib != null)}-gst_v4l2"
    "--${boolEn (v4l_lib != null)}-v4l2-probe"
    "--${boolEn (xorg != null)}-x"
    "--${boolEn (aalib != null)}-aalib"
    "--disable-aalibtest"
    "--${boolEn (cairo != null)}-cairo"
    "--${boolEn (flac != null)}-flac"
    "--${boolEn (gdk-pixbuf != null)}-gdk_pixbuf"
    "--${boolEn (jack2_lib != null)}-jack"
    "--${boolEn (libjpeg != null)}-jpeg"
    "--${boolEn (libcaca != null)}-libcaca"
    "--disable-libdv"
    "--${boolEn (libpng != null)}-libpng"
    "--${boolEn (pulseaudio_lib != null)}-pulse"
    "--disable-dv1394"
    "--${boolEn (libshout != null)}-shout2"
    "--${boolEn (libsoup != null)}-soup"
    "--${boolEn (speex != null)}-speex"
    "--${boolEn (taglib != null)}-taglib"
    "--${boolEn (libvpx != null)}-vpx"
    "--${boolEn (wavpack != null)}-wavpack"
    "--${boolEn (zlib != null)}-zlib"
    "--${boolEn (bzip2 != null)}-bz2"
    "--${boolWt (libgudev != null)}-gudev"
    "--${boolWt (v4l_lib != null)}-libv4l2"
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
