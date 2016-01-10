{ stdenv
, fetchurl
, python

, bzip2
, curl
, faac
, faad2
, flite
, game-music-emu
, glib
, gobject-introspection
, gsm
, gst-plugins-base
, gstreamer
, gtk3
, ladspaH
, libass
, libbs2b
, libmms
, libmodplug
, libmpcdec
, libopus
, librsvg
, libsndfile
, libvdpau
, libvisual
, libwebp
, mesa
, mpg123
, openal
#, opencv
, openh264
, openjpeg
, orc
, schroedinger
, SDL
, soundtouch
, spandsp
#, vo-aacenc
#, vo-armwbenc
, wayland
, x265
, xorg
, xvidcore
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "gst-plugins-bad-1.6.2";

  src = fetchurl {
    url = "http://gstreamer.freedesktop.org/src/gst-plugins-bad/${name}.tar.xz";
    sha256 = "1zlnycgfg7c2pygf21kdacpy2v4jql4j268crfv8nspmkzima235";
  };

  postPatch = ''
    # tests are slower than upstream expects
  	sed -e 's:/\* tcase_set_timeout.*:tcase_set_timeout (tc_chain, 5 * 60);:' \
  		-i tests/check/elements/audiomixer.c
  '';

  configureFlags = [
    "--enable-option-checking"
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-rpath"
    "--disable-fatal-warnings"
    "--disable-debug"
    "--disable-profiling"
    "--disable-valgrind"
    "--disable-gcov"
    "--disable-examples"
    "--enable-external"
    "--enable-experimental"
    "--enable-introspection"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-gobject-cast-checks"
    "--enable-glib-asserts"
    (enFlag "orc" (orc != null) null)
    "--disable-static-plugins"
    # Internal Plugins
    "--enable-accurip"
    "--enable-adpcmdec"
    "--enable-adpcmenc"
    "--enable-aiff"
    "--enable-asfmux"
    "--enable-audiofxbad"
    "--enable-audiomixer"
    "--enable-compositor"
    "--enable-audiovisualizers"
    "--enable-autoconvert"
    "--enable-bayer"
    "--enable-camerabin2"
    "--enable-cdxaparse"
    "--enable-coloreffects"
    "--enable-dataurisrc"
    "--enable-dccp"
    "--enable-debugutils"
    "--enable-dvbsuboverlay"
    "--enable-dvdspu"
    "--enable-faceoverlay"
    "--enable-festival"
    "--enable-fieldanalysis"
    "--enable-freeverb"
    "--enable-frei0r"
    "--enable-gaudieffects"
    "--enable-geometrictransform"
    "--enable-gdp"
    "--enable-hdvparse"
    "--enable-id3tag"
    "--enable-inter"
    "--enable-interlace"
    "--enable-ivfparse"
    "--enable-ivtc"
    "--enable-jp2kdecimator"
    "--enable-jpegformat"
    "--enable-librfb"
    "--enable-liveadder"
    "--enable-midi"
    "--enable-mpegdemux"
    "--enable-mpegtsdemux"
    "--enable-mpegtsmux"
    "--enable-mpegpsmux"
    "--enable-mve"
    "--enable-mxf"
    "--enable-nuvdemux"
    "--enable-onvif"
    "--enable-patchdetect"
    "--enable-pcapparse"
    "--enable-pnm"
    "--enable-rawparse"
    "--enable-removesilence"
    "--enable-rtp"
    "--enable-sdi"
    "--enable-sdp"
    "--enable-segmentclip"
    "--enable-siren"
    "--enable-smooth"
    "--enable-speed"
    "--enable-subenc"
    "--enable-stereo"
    "--enable-tta"
    "--enable-videofilters"
    "--enable-videomeasure"
    "--enable-videoparsers"
    "--enable-videosignal"
    "--enable-vmnc"
    "--enable-y4m"
    "--enable-yadif"
    # External plugins
    "--enable-opengl"
    "--enable-gles2"
    "--enable-egl"
    "--disable-wgl"
    "--enable-glx"
    "--disable-cocoa"
    "--enable-x11"
    "--enable-wayland"
    "--enable-dispmanx"
    "--disable-directsound"
    "--disable-wasapi"
    "--disable-direct3d"
    "--disable-winscreencap"
    "--disable-winks"
    "--disable-android_media"
    "--disable-apple_media"
    "--disable-bluez"
    "--disable-avc"
    (enFlag "shm" (xorg.libXext != null) null)
    #--disable-vcd
    #--disable-opensles
    #--disable-uvch264
    (enFlag "assrender" (libass != null) null)
    #(enFlag "voamrwbenc" (vo-amrwbenc != null) null)
    #(enFlag "voaacenc" (vo-aacenc != null) null)
    #(enFlag "apexsink" ( != null) null)
    (enFlag "bs2b" (libbs2b != null) null)
    (enFlag "bz2" (bzip2 != null) null)
    #(enFlag "chromaprint" ( != null) null)
    (enFlag "curl" (curl != null) null)
    #(enFlag "dash" ( != null) null)
    #(enFlag "dc1394" ( != null) null)
    #(enFlag "decklink" ( != null) null)
    #(enFlag "directfb" ( != null) null)
    (enFlag "wayland" (wayland != null) null)
    (enFlag "webp" (libwebp != null) null)
    #(enFlag "daala" ( != null) null)
    #(enFlag "dts" ( != null) null)
    #(enFlag "resindvd" ( != null) null)
    (enFlag "faac" (faac != null) null)
    (enFlag "faad" (faad2 != null) null)
    #(enFlag "fbdev" ( != null) null)
    (enFlag "flite" (flite != null) null)
    (enFlag "gsm" (gsm != null) null)
    #(enFlag "fluidsynth" ( != null) null)
    #(enFlag "kate" ( != null) null)
    (enFlag "ladspa" (ladspaH != null) null)
    #(enFlag "lv2" ( != null) null)
    #(enFlag "libde265" ( != null) null)
    (enFlag "libmms" (libmms != null) null)
    #(enFlag "srtp" ( != null) null)
    #(enFlag "dtls" ( != null) null)
    #(enFlag "linsys" ( != null) null)
    (enFlag "modplug" (libmodplug != null) null)
    #(enFlag "mimic" ( != null) null)
    #(enFlag "mpeg2enc" ( != null) null)
    (enFlag "mpg123" (mpg123 != null) null)
    #(enFlag "mplex" ( != null) null)
    (enFlag "musepack" (libmpcdec != null) null)
    #(enFlag "nas" ( != null) null)
    #(enFlag "neon" ( != null) null)
    #(enFlag "ofa" ( != null) null)
    (enFlag "openal" (openal != null) null)
    #(enFlag "opencv" (opencv != null) null)
    #(enFlag "openexr" ( != null) null)
    (enFlag "openh264" (openh264 != null) null)
    (enFlag "openjpeg" (openjpeg != null) null)
    #(enFlag "openni2" ( != null) null)
    (enFlag "opus" (libopus != null) null)
    #(enFlag "pvr" ( != null) null)
    (enFlag "rsvg" (librsvg != null) null)
    (enFlag "gl" (mesa != null) null)
    #(enFlag "gtk3" ( != null) null)
    #(enFlag "qt" ( != null) null)
    (enFlag "libvisual" (libvisual != null) null)
    #(enFlag "timidity" ( != null) null)
    #(enFlag "teletextdec" ( != null) null)
    #(enFlag "wildmidi" ( != null) null)
    (enFlag "sdl" (SDL != null) null)
    #(enFlag "sdltest" ( != null) null)
    #(enFlag "smoothstreaming" ( != null) null)
    (enFlag "sndfile" (libsndfile != null) null)
    (enFlag "soundtouch" (soundtouch != null) null)
    #(enFlag "spc" ( != null) null)
    (enFlag "gme" (game-music-emu != null) null)
    (enFlag "xvid" (xvidcore != null) null)
    #(enFlag "dvb" ( != null) null)
    #(enFlag "wininet" ( != null) null)
    #(enFlag "acm" ( != null) null)
    (enFlag "vdpau" (libvdpau != null) null)
    #(enFlag "sbc" ( != null) null)
    (enFlag "schro" (schroedinger != null) null)
    #(enFlag "zbar" ( != null) null)
    #(enFlag "rtmp" ( != null) null)
    (enFlag "spandsp" (spandsp != null) null)
    #(enFlag "gsettings" ( != null) null)
    "--enable-schemas-compile"
    #(enFlag "sndio" ( != null) null)
    #(enFlag "hls" ( != null) null)
    (enFlag "x265" (x265 != null) null)

    "--without-gtk"
  ];

  nativeBuildInputs = [
    python
  ];

  buildInputs = [
    bzip2
    curl
    faac
    faad2
    flite
    game-music-emu
    glib
    gobject-introspection
    gsm
    gst-plugins-base
    gstreamer
    gtk3
    ladspaH
    libass
    libbs2b
    libmms
    libmodplug
    libmpcdec
    libopus
    librsvg
    libvdpau
    libvisual
    libwebp
    mesa
    mpg123
    openal
    #opencv
    openh264
    openjpeg
    orc
    schroedinger
    SDL
    soundtouch
    spandsp
    #vo-aacenc
    #vo-armwbenc
    wayland
    x265
    xorg.libX11
    xvidcore
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Less plugins for GStreamer";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
