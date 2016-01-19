{ stdenv
, fetchTritonPatch
, fetchurl
, gettext

, aalib
, bzip2
, cairo
, flac
, gdk-pixbuf
, glib
, gst-plugins-base_0
, gstreamer_0
, libcaca
, libgudev
, libjack2
, libjpeg
, libpng
, libpulseaudio
, libsoup
, libv4l
, orc
, speex
, taglib
, wavpack
, xorg
, zlib
}:

with {
  inherit (stdenv.lib)
    enFlag
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "gst-plugins-good-0.10.31";

  src = fetchurl {
    url = "http://gstreamer.freedesktop.org/src/gst-plugins-good/${name}.tar.xz";
    sha256 = "0r1b54yixn8v2l1dlwmgpkr0v2a6a21id5njp9vgh58agim47a3p";
  };

  patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "gst-plugins-good/gst-plugins-good-0.10-linux-headers-3.9.patch";
      sha256 = "7879536fb933ac39cfb9f15ec9e4f766c72cac4872e388ae40c1a4a86cb5ae11";
    })
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "gst-plugins-good/gst-plugins-good-0.10-v4l.patch";
      sha256 = "c962291adeb0eb2e5002e8b743d2efa7bcebe7cff199b5d8973fd12b9822899f";
    })
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-rpath"
    "--disable-debug"
    "--disable-profiling"
    "--disable-valgrind"
    "--disable-gcov"
    "--disable-examples"
    "--enable-external"
    "--enable-experimental"
    "--enable-schemas-install"
    "--disable-gtk-doc"
    "--enable-gobject-cast-checks"
    "--enable-glib-asserts"
    (enFlag "orc" (orc != null) null)
    "--enable-gconftool"
    "--enable-videofilter"
    "--enable-alpha"
    "--enable-apetag"
    "--enable-audiofx"
    "--enable-audioparsers"
    "--enable-auparse"
    "--enable-autodetect"
    "--enable-avi"
    "--enable-cutter"
    "--enable-debugutils"
    "--enable-deinterlace"
    "--enable-effectv"
    "--enable-equalizer"
    "--enable-flv"
    "--enable-id3demux"
    "--enable-icydemux"
    "--enable-interleave"
    "--enable-flx"
    "--enable-goom"
    "--enable-goom2k1"
    "--enable-imagefreeze"
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
    "--enable-videomixer"
    "--enable-wavenc"
    "--enable-wavparse"
    "--enable-y4m"
    # External plugins
    "--disable-directsound"
    "--disable-oss"
    "--disable-oss4"
    "--disable-sunaudio"
    "--disable-osx_audio"
    "--disable-osx_video"
    (enFlag "gst_v4l2" (libv4l != null) null)
    (enFlag "x" (xorg.libX11 != null) null)
    (enFlag "xshm" (xorg.libXext != null) null)
    (enFlag "xvideo" (xorg.libXv != null) null)
    (enFlag "aalib" (aalib != null) null)
    "--disable-aalibtest"
    "--disable-annodex"
    (enFlag "cairo" (cairo != null) null)
    "--enable-cairo_gobject"
    "--disable-esd"
    "--disable-esdtest"
    (enFlag "flac" (flac != null) null)
    "--enable-gconf"
    (enFlag "gdk_pixbuf" (gdk-pixbuf != null) null)
    "--disable-hal"
    (enFlag "jack" (libjack2 != null) null)
    (enFlag "jpeg" (libjpeg != null) null)
    (enFlag "libcaca" (libcaca != null) null)
    "--disable-libdv"
    (enFlag "libpng" (libpng != null) null)
    (enFlag "pulse" (libpulseaudio != null) null)
    "--enable-dv1394"
    "--disable-shout2"
    (enFlag "soup" (libsoup != null) null)
    (enFlag "speex" (speex != null) null)
    (enFlag "taglib" (taglib != null) null)
    (enFlag "wavpack" (wavpack != null) null)
    (enFlag "zlib" (zlib != null) null)
    (enFlag "bz2" (bzip2 != null) null)
    "--without-gtk"
    (wtFlag "gudev" (libgudev != null) null)
    (wtFlag "libv4l2" (libv4l != null) null)
    "--with-x"
    #"--with-jpeg-mmx"
  ];

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    aalib
    bzip2
    cairo
    flac
    gdk-pixbuf
    glib
    gst-plugins-base_0
    gstreamer_0
    libcaca
    libgudev
    libjack2
    libjpeg
    libpng
    libpulseaudio
    libsoup
    libv4l
    orc
    speex
    taglib
    wavpack
    xorg.libX11
    xorg.libXext
    xorg.libXv
    zlib
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Basepack of plugins for GStreamer";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.lgpl2plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
