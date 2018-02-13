{ stdenv
, fetchurl
, lib

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
  inherit (lib)
    boolEn
    boolString
    boolWt
    optional
    optionals;

  channel = "0.20";
  version = "${channel}.17";
in
stdenv.mkDerivation rec {
  name = "mpd-${version}";

  src = fetchurl {
    url = "https://www.musicpd.org/download/mpd/${channel}/${name}.tar.xz";
    hashOutput = false;
    multihash = "QmYEHg1reEc4VyMFaWXtERbhsyC1wMVnXLKsxbJmfwzMR4";
    sha256 = "2cb0e7f0e219df60a04b3c997d8ed7ad458ebfd89fd045e03fbe727277d5dac1";
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
    "--enable-daemon"
    "--disable-debug"
    "--${boolEn documentationSupport}-documentation"
    "--enable-dsd"
    "--enable-fifo"
    "--enable-httpd-output"
    "--enable-inotify"
    "--enable-ipv6"
    "--enable-largefile"
    "--${boolEn (yajl != null)}-soundcloud"
    # TODO: libwrap support
    #"--${boolEn }-libwrap" true null)
    "--disable-libwrap"
    "--${boolEn (libmikmod != null)}-mikmod"
    "--${boolEn (openal != null)}-openal"
    "--disable-oss"
    "--disable-osx"
    "--enable-pipe-output"
    "--enable-recorder-output"
    # TODO: sidplay
    "--disable-sidplay"
    "--${boolEn (libshout != null)}-shout"
    "--disable-solaris-output"
    "--enable-tcp"
    "--disable-test"
    "--enable-un"
    "--${boolEn (libvorbis != null)}-vorbis"
    "--enable-wave-encoder"
    "--disable-werror"
    "--${boolEn (icu != null)}-icu"
    "--enable-iconv"
    "--${boolEn (systemd_lib != null)}-systemd-daemon"
    "--${boolEn (libmpdclient != null)}-libmpdclient"
    "--${boolEn (expat != null)}-expat"
    "--${boolEn (libid3tag != null)}-id3"
    "--${boolEn (sqlite != null)}-sqlite"
    "--${boolEn (libsamplerate != null)}-lsr"
    "--${boolEn (soxr != null)}-soxr"
    "--${boolEn (curl != null)}-curl"
    "--${boolEn (samba_client != null)}-smbclient"
    # TODO: nfs support
    "--disable-nfs"
    # TODO: cdio-paranoia support
    #"--${boolEn (libcdio != null)}-cdio-paranoia"
    "--disable-paranoia"
    "--${boolEn (libmms != null)}-mms"
    "--enable-webdav"
    "--enable-cue"
    "--enable-neighbor-plugins"
    # TODO: iso9660
    "--disable-iso9660"
    "--${boolEn (zlib != null)}-zlib"
    "--${boolEn (bzip2 != null)}-bzip2"
    "--${boolEn (libupnp != null)}-upnp"
    "--${boolEn (zziplib != null)}-zzip"
    # TODO: adplug support
    #"--${boolEn }-adplug" true null)
    "--disable-adplug"
    "--${boolEn (audiofile != null)}-audiofile"
    "--disable-aac"
    "--${boolEn (ffmpeg != null)}-ffmpeg"
    "--${boolEn (flac != null)}-flac"
    "--${boolEn (fluidsynth != null)}-fluidsynth"
    "--${boolEn (game-music-emu != null)}-gme"
    "--${boolEn (libmad != null)}-mad"
    "--${boolEn (mpg123 != null)}-mpg123"
    "--${boolEn (libmodplug != null)}-modplug"
    "--${boolEn (opus != null)}-opus"
    "--${boolEn (libsndfile != null)}-sndfile"
    "--${boolEn (musepack != null)}-mpc"
    "--${boolEn (wavpack != null)}-wavpack"
    # TODO: wildmidi
    "--disable-wildmidi"
    # TODO: shine
    #"--${boolEn (shine != null)}-shine-encoder"
    "--disable-shine-encoder"
    "--${boolEn (libvorbis != null)}-vorbis-encoder"
    "--${boolEn (lame != null)}-lame-encoder"
    # TODO: twolame support
    #"--${boolEn (twolame != null)}-twolame-encoder"
    "--disable-twolame-encoder"
    "--${boolEn (alsa-lib != null)}-alsa"
    "--disable-roar"
    # TODO: sndio
    #"--${boolEn (libsndio != null)}-sndio"
    "--disable-haiku"
    "--${boolEn (jack2_lib != null)}-jack"
    "--${boolEn (libao != null)}-ao"
    "--${boolEn (pulseaudio_lib != null)}-pulse"
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

  meta = with lib; {
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
