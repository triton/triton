{ stdenv
, fetchurl
, lib
, python3

, bzip2
, chromaprint
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
, gtk_3
, ladspa-sdk
, libass
, libbs2b
, libmms
, libmodplug
, librsvg
, libsndfile
, libvdpau
, libvisual
, libwebp
, mesa
, musepack
, openal
, opencv
, openexr
, openh264
, openjpeg
#, openssl
, opus
, orc
, qt5
, rtmpdump
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

, channel
}:

let
  inherit (lib)
    boolEn
    boolString
    boolWt;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "gst-plugins-bad-${source.version}";

  src = fetchurl rec {
    urls = map (n: "${n}/${name}.tar.xz") [
      "https://gstreamer.freedesktop.org/src/gst-plugins-bad"
      "mirror://gnome/sources/gst-plugins-bad/${channel}"
    ];
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    python3
  ];

  buildInputs = [
    bzip2
    chromaprint
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
    gtk_3
    ladspa-sdk
    libass
    libbs2b
    libmms
    libmodplug
    opus
    librsvg
    libvdpau
    libvisual
    libwebp
    mesa
    musepack
    openal
    opencv
    openexr
    openh264
    openjpeg
    #openssl
    orc
    qt5
    rtmpdump
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

  postPatch =
    /* tests are slower than upstream expects */ ''
      sed -e 's:/\* tcase_set_timeout.*:tcase_set_timeout (tc_chain, 5 * 60);:' \
        -i tests/check/elements/audiomixer.c
    '';

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
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-gobject-cast-checks"
    "--disable-glib-asserts"
    "--enable-Bsymbolic"
    "--${boolEn (orc != null)}-orc"
    "--disable-static-plugins"
    # Internal Plugins
    "--enable-accurip"
    "--enable-adpcmdec"
    "--enable-adpcmenc"
    "--enable-aiff"
    "--enable-videoframe_audiolevel"
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
    "--enable-midi"
    "--enable-mpegdemux"
    "--enable-mpegtsdemux"
    "--enable-mpegtsmux"
    "--enable-mpegpsmux"
    "--enable-mve"
    "--enable-mxf"
    "--enable-netsim"
    "--enable-nuvdemux"
    "--enable-onvif"
    "--enable-patchdetect"
    "--enable-pcapparse"
    "--enable-pnm"
    "--enable-rawparse"
    "--enable-removesilence"
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
    "--${boolEn (mesa != null)}-opengl"
    "--${boolEn (mesa != null)}-gles2"
    "--${boolEn (mesa != null)}-egl"
    "--disable-wgl"
    "--${boolEn (mesa != null)}-glx"
    "--disable-cocoa"  # macos
    "--${boolEn (xorg.libX11 != null)}-x11"
    "--${boolEn (wayland != null)}-wayland"
    "--enable-dispmanx"
    "--disable-directsound"  # windows
    "--disable-wasapi"  # windows
    "--disable-direct3d"  # windows
    "--disable-winscreencap"  # windows
    "--disable-winks"
    "--disable-android_media"  # android
    "--disable-apple_media"  # macos
    "--disable-bluez"
    "--disable-avc"
    "--${boolEn (xorg != null)}-shm"
    /**/"--disable-vcd"
    "--disable-opensles"  # android
    /**/"--disable-uvch264"
    /**/"--disable-nvenc"
    /**/"--disable-tinyalsa"
    "--${boolEn (libass != null)}-assrender"
    /**/"--disable-voamrwbenc"
    /**/"--disable-voaacenc"
    /**/"--disable-apexsink"
    "--${boolEn (libbs2b != null)}-bs2b"
    "--${boolEn (bzip2 != null)}-bz2"
    "--${boolEn (chromaprint != null)}-chromaprint"
    "--${boolEn (curl != null)}-curl"
    /**/"--disable-dash"
    /**/"--disable-dc1394"
    /**/"--disable-decklink"
    /**/"--disable-directfb"
    "--${boolEn (wayland != null)}-wayland"  #"
    "--${boolEn (libwebp != null)}-webp"
    /**/"--disable-daala"
    /**/"--disable-dts"
    /**/"--disable-resindvd"
    "--${boolEn (faac != null)}-faac"
    "--${boolEn (faad2 != null)}-faad"
    /**/"--disable-fbdev"
    "--${boolEn (flite != null)}-flite"
    "--${boolEn (gsm != null)}-gsm"
    /**/"--disable-fluidsynth"
    /**/"--disable-kate"
    /**/"--disable-kms"
    "--${boolEn (ladspa-sdk != null)}-ladspa"
    /**/"--disable-lv2"
    /**/"--disable-libde265"
    "--${boolEn (libmms != null)}-libmms"
    /**/"--disable-srtp"
    /**/"--disable-dtls"
    /**/"--disable-linsys"
    "--${boolEn (libmodplug != null)}-modplug"
    /**/"--disable-mimic"
    /**/"--disable-mpeg2enc"
    /**/"--disable-mplex"
    "--${boolEn (musepack != null)}-musepack"
    /**/"--disable-nas"
    /**/"--disable-neon"
    /**/"--disable-ofa"
    "--${boolEn (openal != null)}-openal"
    "--${boolEn (opencv != null)}-opencv"
    "--${boolEn (openexr != null)}-openexr"
    "--${boolEn (openh264 != null)}-openh264"
    "--${boolEn (openjpeg != null)}-openjpeg"
    /**/"--disable-openni2"
    "--${boolEn (opus != null)}-opus"
    /**/"--disable-pvr"
    "--${boolEn (librsvg != null)}-rsvg"
    "--${boolEn (mesa != null)}-gl"
    "--${boolEn (gtk_3 != null)}-gtk3"
    "--${boolEn (qt5 != null)}-qt"
    /**/"--disable-vulkan"
    "--${boolEn (libvisual != null)}-libvisual"
    /**/"--disable-timidity"
    /**/"--disable-teletextdec"
    /**/"--disable-wildmidi"
    "--${boolEn (SDL != null)}-sdl"
    "--disable-sdltest"
    /**/"--disable-smoothstreaming"
    "--${boolEn (libsndfile != null)}-sndfile"
    "--${boolEn (soundtouch != null)}-soundtouch"
    /**/"--disable-spc"
    "--${boolEn (game-music-emu != null)}-gme"
    "--${boolEn (xvidcore != null)}-xvid"
    /**/"--disable-svb"
    "--disable-wininet"  # windows
    /**/"--disable-acm"
    "--${boolEn (libvdpau != null)}-vdpau"
    /**/"--disable-sbc"
    "--${boolEn (schroedinger != null)}-schro"
    /**/"--disable-zbar"
    "--${boolEn (rtmpdump != null)}-rtmp"
    "--${boolEn (spandsp != null)}-spandsp"
    /**/"--disable-gsettings"
    "--enable-schemas-compile"
    /**/"--disable-sndio"
    /**/"--disable-hls"
    "--${boolEn (x265 != null)}-x265"
    "--enable-webrtcdsp"
    "--${boolWt (gtk_3 != null)}-gtk${boolString (gtk_3 != null) "=3.0" ""}"
    #"--with-hls-crypto=openssl"
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
    description = "Less plugins for GStreamer";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
