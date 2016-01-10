{ stdenv
, fetchurl
, gettext
, python

, bzip2
, celt
, curl
, faac
, faad2
, flite
, game-music-emu
, glib
, gsm
, gst-plugins-base_0
, gstreamer_0
, libass
, libmms
, libmodplug
, libmusicbrainz
, libopus
, librsvg
, libsndfile
, libvdpau
, libvpx
, openal
, orc
, schroedinger
, SDL
, soundtouch
, spandsp
, xvidcore
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "gst-plugins-bad-0.10.23";

  src = fetchurl {
    url = "http://gstreamer.freedesktop.org/src/gst-plugins-bad/${name}.tar.bz2";
    sha256 = "148lw51dm6pgw8vc6v0fpvm7p233wr11nspdzmvq7bjp2cd7vbhf";
  };

  patches = [
    # Patch from 0.10 branch fixing h264 baseline decoding
    ./gst-plugins-bad-0.10.23-CVE-2015-0797.patch
  ];

  configureFlags = [
    "--enable-option-checking"
    "--enable-nls"
    "--enable-rpath"
    "--disable-debug"
    "--disable-profiling"
    "--disable-valgrind"
    "--disable-gcov"
    "--disable-examples"
    "--enable-external"
    "--enable-experimental"
    "--disable-gtk-doc"
    "--enable-gobject-cast-checks"
    "--enable-glib-asserts"
    (enFlag "orc" (orc != null) null)
    "--enable-adpcmdec"
    "--enable-adpcmenc"
    "--enable-aiff"
    "--enable-asfmux"
    "--enable-audiovisualizers"
    "--enable-autoconvert"
    "--enable-bayer"
    "--enable-camerabin"
    "--enable-camerabin2"
    "--enable-cdxaparse"
    "--enable-coloreffects"
    "--enable-colorspace"
    "--enable-dataurisrc"
    "--enable-dccp"
    "--enable-debugutils"
    "--enable-dtmf"
    "--enable-dvbsuboverlay"
    "--enable-dvdspu"
    "--enable-faceoverlay"
    "--enable-festival"
    "--enable-fieldanalysis"
    "--enable-freeze"
    "--enable-freeverb"
    "--enable-frei0r"
    "--enable-gaudieffects"
    "--enable-geometrictransform"
    "--enable-h264parse"
    "--enable-hdvparse"
    "--enable-hls"
    "--enable-id3tag"
    "--enable-inter"
    "--enable-interlace"
    "--enable-ivfparse"
    "--enable-jp2kdecimator"
    "--enable-jpegformat"
    "--enable-legacyresample"
    "--enable-librfb"
    "--enable-liveadder"
    "--enable-mpegdemux"
    "--enable-mpegtsdemux"
    "--enable-mpegtsmux"
    "--enable-mpegpsmux"
    "--enable-mpegvideoparse"
    "--enable-mve"
    "--enable-mxf"
    "--enable-nsf"
    "--enable-nuvdemux"
    "--enable-patchdetect"
    "--enable-pcapparse"
    "--enable-pnm"
    "--enable-rawparse"
    "--enable-real"
    "--enable-removesilence"
    "--enable-rtpmux"
    "--enable-rtpvp8"
    "--enable-scaletempo"
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
    "--enable-videomaxrate"
    "--enable-videomeasure"
    "--enable-videoparsers"
    "--enable-videosignal"
    "--enable-vmnc"
    "--enable-y4m"
    "--disable-directsound"
    "--disable-direct3d"
    "--disable-directdraw"
    "--disable-apple_media"
    "--disable-osx_video"
    "--disable-avc"
    "--disable-quicktime"
    "--enable-shm"
    "--enable-vcd"
    (enFlag "assrender" (libass != null) null)
    #(enFlag "voamrwbenc" (vo-amrwbenc != null) null)
    #(enFlag "voaacenc" (vo-accenc != null) null)
    # ???
    #"--enable-apexsink"
    (enFlag "bz2" (bzip2 != null) null)
    #"--enable-cdaudio"
    (enFlag "celt" (celt != null) null)
    #"--enable-cog"
    (enFlag "curl" (curl != null) null)
    #"--enable-dc1394"
    #"--disable-decklink"
    #"--disable-directfb"
    (enFlag "dirac" (schroedinger != null) null)
    #"--enable-dts"
    #"--enable-divx"
    #"--enable-resindvd"
    (enFlag "faac" (faac != null) null)
    (enFlag "faad" (faad2 != null) null)
    #"--enable-fbdev"
    (enFlag "flite" (flite != null) null)
    (enFlag "gsm" (gsm != null) null)
    #"--enable-jp2k" openjpeg?
    #"--enable-kate"
    #"--enable-ladspa"
    #"--enable-lv2"
    (enFlag "libmms" (libmms != null) null)
    #"--enable-linsys"
    #(enFlag "modplug" (libmodplug != null) null)
    #"--enable-mimic"
    #"--enable-mpeg2enc"
    #"--enable-mplex"
    #"--enable-musepack"
    (enFlag "musicbrainz" (libmusicbrainz != null) null)
    #"--enable-mythtv"
    #"--enable-nas"
    #"--enable-neon"
    #"--enable-ofa"
    (enFlag "openal" (openal != null) null)
    #"--enable-opencv"
    #(enFlag "opus" (libopus != null) null)
    #"--enable-pvr"
    (enFlag "rsvg" (librsvg != null) null)
    #"--enable-timidity"
    #"--enable-teletextdec"
    #"--enable-wildmidi"
    (enFlag "sdl" (SDL != null) null)
    #"--enable-sdltest"
    (enFlag "sndfile" (libsndfile != null) null)
    (enFlag "soundtouch" (soundtouch != null) null)
    #"--enable-spc"
    (enFlag "gme" (game-music-emu != null) null)
    #"--enable-swfdec"
    (enFlag "xvid" (xvidcore != null) null)
    #"--enable-dvb"
    "--disable-wininet"
    "--disable-acm"
    (enFlag "vdpau" (libvdpau != null) null)
    (enFlag "schro" (schroedinger != null) null)
    #"--disable-zbar"
    #(enFlag "vp8" (libvpx != null) null)
    #"--enable-rtmp"
    (enFlag "spandsp" (spandsp != null) null)
    #"--enable-gsettings"
    "--enable-schemas-compile"
    "--without-gtk"
    "--with-x"
  ];

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    bzip2
    celt
    curl
    faac
    faad2
    flite
    game-music-emu
    glib
    gsm
    gst-plugins-base_0
    gstreamer_0
    libass
    libmms
    #libmodplug
    libmusicbrainz
    #libopus
    librsvg
    libsndfile
    libvdpau
    #libvpx
    openal
    orc
    schroedinger
    SDL
    soundtouch
    spandsp
    xvidcore
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
