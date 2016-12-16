{ stdenv
, fetchurl

# Required
, boost
, glib

# Optional
, alsa-lib
, audiofile
, avahi
, bzip2
, curl
, dbus
, expat
, ffmpeg
, flac
, fluidsynth
, game-music-emu
, icu
, jack2_lib
, lame
, libao
, libid3tag
, libmad
, libmikmod
, libmms
, libmodplug
, libmpdclient
, libogg
, libsamplerate
, libshout
, libsndfile
, libupnp
, libvorbis
, mpg123
, openal
, opus
, pulseaudio_lib
, soxr
, sqlite
, systemd_lib
#, twolame
, wavpack
, yajl
, zlib
, zziplib
# Options
, documentationSupport ? false
  , xmlto
  , doxygen
}:

let
  inherit (stdenv.lib)
    boolEn
    boolString
    boolWt
    optional
    optionals;

  versionMajor = "0.19";
  versionMinor = "21";
in
stdenv.mkDerivation rec {
  name = "mpd-${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "https://www.musicpd.org/download/mpd/${versionMajor}/${name}.tar.xz";
    hashOutput = false;
    multihash = "QmNNP6SRdaAAWXXbN4wDvWLdWVTxVsAcSrVaHtJAyqds7V";
    sha256 = "8305b8bc026f4b6bde28b8dd09bfdddbe5590acf36358eed4d083a396e301730";
  };

  nativeBuildInputs = [ ] ++ optionals documentationSupport [
    doxygen
    xmlto
  ];

  buildInputs = [
    # Required
    boost
    glib
    # Optional
    alsa-lib
    audiofile
    avahi
    bzip2
    curl
    dbus
    expat
    ffmpeg
    flac
    fluidsynth
    game-music-emu
    icu
    jack2_lib
    lame
    libao
    libid3tag
    libmad
    libmikmod
    libmms
    libmodplug
    libmpdclient
    libogg
    libsamplerate
    libshout
    libsndfile
    libupnp
    libvorbis
    mpg123
    openal
    opus
    pulseaudio_lib
    soxr
    sqlite
    systemd_lib
    wavpack
    yajl
    zlib
    zziplib
  ];

  configureFlags = [
    "--disable-aac"
    # TODO: adplug support
    #"--${boolEn }-adplug" true null)
    "--${boolEn (alsa-lib != null)}-alsa"
    "--${boolEn (audiofile != null)}-audiofile"
    "--${boolEn (bzip2 != null)}-bzip2"
    # TODO: cdio-paranoia support
    #"--${boolEn (libcdio != null)}-cdio-paranoia"
    "--${boolEn (curl != null)}-curl"
    "--enable-database"
    "--enable-dsd"
    "--enable-fifo"
    "--${boolEn (ffmpeg != null)}-ffmpeg"
    "--${boolEn (flac != null)}-flac"
    "--${boolEn (fluidsynth != null)}-fluidsynth"
    "--${boolEn (game-music-emu != null)}-gme"
    "--disable-haiku"
    "--enable-httpd-output"
    "--enable-iconv"
    "--${boolEn (icu != null)}-icu"
    "--${boolEn (libid3tag != null)}-id3"
    "--enable-inotify"
    "--enable-ipv6"
    "--${boolEn (jack2_lib != null)}-jack"
    "--${boolEn (lame != null)}-lame-encoder"
    "--${boolEn (libmpdclient != null)}-libmpdclient"
    # TODO: libwrap support
    #"--${boolEn }-libwrap" true null)
    "--${boolEn (libsndfile != null)}-sndfile"
    "--${boolEn (libsamplerate != null)}-lsr"
    "--${boolEn (libmad != null)}-mad"
    "--${boolEn (libmikmod != null)}-mikmod"
    "--${boolEn (libmms != null)}-mms"
    "--${boolEn (libmodplug != null)}-modplug"
    "--${boolEn (mpg123 != null)}-mpg123"
    "--enable-neighbor-plugins"
    "--${boolEn (openal != null)}-openal"
    "--${boolEn (opus != null)}-opus"
    "--disable-oss"
    "--disable-osx"
    "--enable-pipe-output"
    "--${boolEn (pulseaudio_lib != null)}-pulse"
    "--${boolEn (libshout != null)}-shout"
    "--disable-solaris-output"
    "--${boolEn (yajl != null)}-soundcloud"
    "--${boolEn (sqlite != null)}-sqlite"
    # TODO: twolame support
    #"--${boolEn (twolame != null)}-twolame"
    "--enable-un"
    "--${boolEn (libupnp != null)}-upnp"
    "--${boolEn (libvorbis != null)}-vorbis"
    "--${boolEn (libvorbis != null)}-vorbis-encoder"
    "--enable-wave-encoder"
    "--${boolEn (wavpack != null)}-wavpack"
    "--${boolWt (avahi != null && dbus != null)}-zeroconf${
        boolString (avahi != null && dbus != null) "=avahi" ""}"
    "--${boolEn (zlib != null)}-zlib"
    "--${boolEn (zziplib != null)}-zzip"
    "--${boolWt (systemd_lib != null)}-systemdsystemunitdir${
        boolString (systemd_lib != null) "=$(out)/etc/systemd/system" ""}"
    "--disable-debug"
    "--${boolEn documentationSupport}-documentation"
    "--disable-werror"
  ];

  NIX_LDFLAGS = [ ] ++ optional (libshout != null) "-lshout";

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrl = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "0392 335A 7808 3894 A430  1C43 236E 8A58 C6DB 4512";
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
    description = "A flexible, powerful daemon for playing music";
    homepage = http://www.musicpd.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
