{ stdenv
, fetchurl
, lib
, python3

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
, librsvg
, libsndfile
, libvdpau
, libvisual
, libwebp
, mesa
, musepack
, openal
#, opencv
, openh264
, openjpeg
, opus
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

, channel
}:

let
  inherit (lib)
    boolEn;

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
    opus
    librsvg
    libvdpau
    libvisual
    libwebp
    mesa
    musepack
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
    "--${boolEn (xorg != null)}-shm"
    #--disable-vcd
    #--disable-opensles
    #--disable-uvch264
    #"--disable-nvenc"
    #"--disable-tinyalsa"
    "--${boolEn (libass != null)}-assrender"
    #"--${boolEn (vo-amrwbenc != null)}-voamrwbenc"
    #"--${boolEn (vo-aacenc != null)}-voaacenc"
    #"--${boolEn ( != null)}-apexsink"
    "--${boolEn (libbs2b != null)}-bs2b"
    "--${boolEn (bzip2 != null)}-bz2"
    #"--${boolEn ( != null)}-chromaprint"
    "--${boolEn (curl != null)}-curl"
    #"--${boolEn ( != null)}-dash"
    #"--${boolEn ( != null)}-dc1394"
    #"--${boolEn ( != null)}-decklink"
    #"--${boolEn ( != null)}-directfb"
    "--${boolEn (wayland != null)}-wayland"
    "--${boolEn (libwebp != null)}-webp"
    #"--${boolEn ( != null)}-daala"
    #"--${boolEn ( != null)}-dts"
    #"--${boolEn ( != null)}-resindvd"
    "--${boolEn (faac != null)}-faac"
    "--${boolEn (faad2 != null)}-faad"
    #"--${boolEn ( != null)}-fbdev"
    "--${boolEn (flite != null)}-flite"
    "--${boolEn (gsm != null)}-gsm"
    #"--${boolEn ( != null)}-fluidsynth"
    #"--${boolEn ( != null)}-kate"
    "--${boolEn (ladspaH != null)}-ladspa"
    #"--${boolEn ( != null)}-lv2"
    #"--${boolEn ( != null)}-libde265"
    "--${boolEn (libmms != null)}-libmms"
    #"--${boolEn ( != null)}-srtp"
    #"--${boolEn ( != null)}-dtls"
    #"--${boolEn ( != null)}-linsys"
    "--${boolEn (libmodplug != null)}-modplug"
    #"--${boolEn ( != null)}-mimic"
    #"--${boolEn ( != null)}-mpeg2enc"
    #"--${boolEn ( != null)}-mplex"
    "--${boolEn (musepack != null)}-musepack"
    #"--${boolEn ( != null)}-nas"
    #"--${boolEn ( != null)}-neon"
    #"--${boolEn ( != null)}-ofa"
    "--${boolEn (openal != null)}-openal"
    #"--${boolEn (opencv != null)}-opencv"
    #"--${boolEn ( != null)}-openexr"
    "--${boolEn (openh264 != null)}-openh264"
    "--${boolEn (openjpeg != null)}-openjpeg"
    #"--${boolEn ( != null)}-openni2"
    "--${boolEn (opus != null)}-opus"
    #"--${boolEn ( != null)}-pvr"
    "--${boolEn (librsvg != null)}-rsvg"
    "--${boolEn (mesa != null)}-gl"
    #"--${boolEn ( != null)}-gtk3"
    #"--${boolEn ( != null)}-qt"
    #"--disable-vulkan"
    "--${boolEn (libvisual != null)}-libvisual"
    #"--${boolEn ( != null)}-timidity"
    #"--${boolEn ( != null)}-teletextdec"
    #"--${boolEn ( != null)}-wildmidi"
    "--${boolEn (SDL != null)}-sdl"
    #"--${boolEn ( != null)}-sdltest"
    #"--${boolEn ( != null)}-smoothstreaming"
    "--${boolEn (libsndfile != null)}-sndfile"
    "--${boolEn (soundtouch != null)}-soundtouch"
    #"--${boolEn ( != null)}-spc"
    "--${boolEn (game-music-emu != null)}-gme"
    "--${boolEn (xvidcore != null)}-xvid"
    #"--${boolEn ( != null)}-dvb"
    #"--${boolEn ( != null)}-wininet"
    #"--${boolEn ( != null)}-acm"
    "--${boolEn (libvdpau != null)}-vdpau"
    #"--${boolEn ( != null)}-sbc"
    "--${boolEn (schroedinger != null)}-schro"
    #"--${boolEn ( != null)}-zbar"
    #"--${boolEn ( != null)}-rtmp"
    "--${boolEn (spandsp != null)}-spandsp"
    #"--${boolEn ( != null)}-gsettings"
    "--enable-schemas-compile"
    #"--${boolEn ( != null)}-sndio"
    #"--${boolEn ( != null)}-hls"
    "--${boolEn (x265 != null)}-x265"

    "--without-gtk"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = map (n: "${n}.sha256sum") src.urls;
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
