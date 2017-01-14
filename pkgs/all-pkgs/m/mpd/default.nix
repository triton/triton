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
, musepack
, openal
, opus
, pulseaudio_lib
, samba_client
#, shine
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

  versionMajor = "0.20";
  versionMinor = "1";
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
    musepack
    openal
    opus
    pulseaudio_lib
    samba_client
    #shine
    soxr
    sqlite
    systemd_lib
    wavpack
    yajl
    zlib
    zziplib
  ];

  postPatch = /* Fix systemd detection (0.20.1) */ ''
    sed -i configure \
      -e 's/libsystemd-daemon/libsystemd/g'
  '';

  configureFlags = [
    "--enable-database"
    "--${boolEn (libmpdclient != null)}-libmpdclient"
    "--${boolEn (expat != null)}-expat"
    "--${boolEn (libupnp != null)}-upnp"
    # TODO: adplug support
    #"--${boolEn }-adplug" true null)
    "--disable-adplug"
    "--${boolEn (alsa-lib != null)}-alsa"
    "--disable-roar"
    "--${boolEn (libao != null)}-ao"
    "--${boolEn (audiofile != null)}-audiofile"
    "--${boolEn (zlib != null)}-zlib"
    "--${boolEn (bzip2 != null)}-bzip2"
    # TODO: cdio-paranoia support
    #"--${boolEn (libcdio != null)}-cdio-paranoia"
    "--disable-paranoia"
    "--${boolEn (curl != null)}-curl"
    "--${boolEn (samba_client != null)}-smbclient"
    # TODO: nfs support
    "--disable-nfs"
    "--disable-debug"
    "--${boolEn documentationSupport}-documentation"
    "--enable-dsd"
    "--${boolEn (ffmpeg != null)}-ffmpeg"
    "--enable-fifo"
    "--${boolEn (flac != null)}-flac"
    "--${boolEn (fluidsynth != null)}-fluidsynth"
    "--${boolEn (game-music-emu != null)}-gme"
    "--enable-httpd-output"
    "--${boolEn (libid3tag != null)}-id3"
    # TODO: iso9660
    "--disable-iso9660"
    "--${boolEn (jack2_lib != null)}-jack"
    "--enable-largefile"
    "--${boolEn (yajl != null)}-soundcloud"
    "--${boolEn (lame != null)}-lame-encoder"
    # TODO: libwrap support
    #"--${boolEn }-libwrap" true null)
    "--disable-libwrap"
    "--${boolEn (libsamplerate != null)}-lsr"
    "--${boolEn (soxr != null)}-soxr"
    "--${boolEn (libmad != null)}-mad"
    "--${boolEn (libmikmod != null)}-mikmod"
    "--${boolEn (libmms != null)}-mms"
    "--${boolEn (libmodplug != null)}-modplug"
    "--${boolEn (musepack != null)}-mpc"
    "--${boolEn (mpg123 != null)}-mpg123"
    "--${boolEn (openal != null)}-openal"
    "--${boolEn (opus != null)}-opus"
    "--disable-oss"
    "--disable-osx"
    "--enable-pipe-output"
    "--${boolEn (pulseaudio_lib != null)}-pulse"
    "--enable-recorder-output"
    # TODO: sidplay
    "--disable-sidplay"
    # TODO: shine
    #"--${boolEn (shine != null)}-shine-encoder"
    "--disable-shine-encoder"
    "--${boolEn (libshout != null)}-shout"
    "--${boolEn (libsndfile != null)}-sndfile"
    "--disable-solaris-output"
    "--${boolEn (sqlite != null)}-sqlite"
    "--${boolEn (systemd_lib != null)}-systemd-daemon"
    "--enable-tcp"
    "--disable-test"
    # TODO: twolame support
    #"--${boolEn (twolame != null)}-twolame-encoder"
    "--disable-twolame-encoder"
    "--enable-un"
    "--${boolEn (libvorbis != null)}-vorbis"
    "--${boolEn (libvorbis != null)}-vorbis-encoder"
    "--enable-wave-encoder"
    "--${boolEn (wavpack != null)}-wavpack"
    "--disable-werror"
    # TODO: wildmidi
    "--disable-wildmidi"
    "--${boolEn (zziplib != null)}-zzip"
    "--${boolEn (icu != null)}-icu"
    "--${boolEn (glib != null)}-glib"
    "--enable-neighbor-plugins"
    "--enable-aac"
    "--${boolWt (systemd_lib != null)}-systemdsystemunitdir${
        boolString (systemd_lib != null) "=$(out)/etc/systemd/system" ""}"
    "--${boolWt (avahi != null && dbus != null)}-zeroconf${
        boolString (avahi != null && dbus != null) "=avahi" ""}"
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
