{ stdenv
, fetchurl
, lib
, meson
, ninja

, alsa-lib
, audiofile
, avahi
, boost
, bzip2
, chromaprint
, curl
, dbus
, expat
, ffmpeg
, fluidsynth
, game-music-emu
, icu
, jack2_lib
, lame
, libao
, libcdio
, libcdio-paranoia
, libgcrypt
#, libid3tag
, libmikmod
, libmms
, libmodplug
, libmpdclient
, libnfs
#, libogg
, libshout
, libsndfile
, libupnp
#, libvorbis
, musepack
, openal
, pcre
, pulseaudio_lib
, samba_client
, soxr
, sqlite
, systemd_lib
, udisks
, yajl
, zlib
, zziplib

, documentationSupport ? false
  , python3Packages
}:

let
  inherit (lib)
    boolEnd
    boolString
    #optional
    optionals;

  channel = "0.21";
  version = "${channel}.5";
in
stdenv.mkDerivation rec {
  name = "mpd-${version}";

  src = fetchurl {
    url = "https://www.musicpd.org/download/mpd/${channel}/${name}.tar.xz";
    hashOutput = false;
    multihash = "QmbpKgWc9mBrg2cQNiKvaurY1nC5G3yvinaKrh5k6xHSEK ";
    sha256 = "2ea9f0eb3a7bdae5d705adf4e8ec45ef38b5b9ddf133f32b8926dd4e205b0ef9";
  };

  nativeBuildInputs = [
    meson
    ninja
  ] ++ optionals documentationSupport [
    python3Packages.sphinx
  ];

  buildInputs = [
    alsa-lib
    audiofile
    avahi
    boost
    bzip2
    chromaprint
    curl
    dbus
    expat
    ffmpeg
    fluidsynth
    game-music-emu
    icu
    jack2_lib
    lame
    libao
    libcdio
    libcdio-paranoia
    #libid3tag
    libgcrypt
    libmikmod
    libmms
    libmodplug
    libmpdclient
    libnfs
    #libogg
    libshout
    libsndfile
    libupnp
    #libvorbis
    musepack
    openal
    pcre
    pulseaudio_lib
    samba_client
    soxr
    sqlite
    systemd_lib
    udisks
    yajl
    zlib
    zziplib
  ];

  mesonFlags = [
    "-Dsyslog=disabled"
    "-Dsystemd=enabled"
    "-Dipv6=enabled"
    "-Dupnp=${boolEnd (libupnp != null)}"
    "-Dlibmpdclient=enabled"
    "-Dudisks=${boolEnd (udisks != null)}"
    "-Dwebdav=${boolEnd (expat != null)}"
    "-Dcdio_paranoia=enabled"
    "-Dcurl=enabled"
    "-Dmms=${boolEnd (libmms != null)}"
    "-Dnfs=${boolEnd (libnfs != null)}"
    "-Dsmbclient=${boolEnd (samba_client != null)}"
    "-Dqobuz=${boolEnd (libgcrypt != null && yajl != null)}"
    "-Dsoundcloud=${boolEnd (yajl != null)}"
    "-Dtidal=${boolEnd (yajl != null)}"
    "-Dbzip2=${boolEnd (bzip2 != null)}"
    "-Diso9660=enabled"
    "-Dzzip=${boolEnd (zziplib != null)}"
    "-Did3tag=disabled"  # FIXME
    "-Dchromaprint=${boolEnd (chromaprint != null)}"
    "-Dadplug=disabled"  # TODO
    "-Daudiofile=${boolEnd (audiofile != null)}"
    "-Dfaad=disabled"  # ffmpeg
    "-Dffmpeg=enabled"
    "-Dflac=disabled"  # ffmpeg
    "-Dfluidsynth=${boolEnd (fluidsynth != null)}"
    "-Dgme=${boolEnd (game-music-emu != null)}"
    "-Dmad=disabled"  # ffmpeg
    "-Dmikmod=${boolEnd (libmikmod != null)}"
    "-Dmodplug=${boolEnd (libmodplug != null)}"
    "-Dmpcdec=${boolEnd (musepack != null)}"
    "-Dmpg123=disabled"  # ffmpeg
    "-Dopus=disabled"  # ffmpeg
    "-Dsidplay=disabled"  # TODO
    "-Dsndfile=${boolEnd (libsndfile != null)}"
    "-Dtremor=disabled"  # ffmpeg
    "-Dvorbis=disabled"  # ffmpeg
    "-Dwavpack=disabled"  # ffmpeg
    "-Dwildmidi=disabled"  # TODO
    "-Dvorbisenc=disabled"  # FIXME
    "-Dlame=enabled"
    "-Dtwolame=disabled"
    "-Dshine=disabled"
    "-Dlibsamplerate=disabled"
    "-Dsoxr=enabled"
    "-Dalsa=enabled"
    "-Dao=${boolEnd (libao != null)}"
    "-Djack=${boolEnd (jack2_lib != null)}"
    "-Dopenal=${boolEnd (openal != null)}"
    "-Doss=disabled"
    "-Dpulse=enabled"
    "-Dshout=${boolEnd (libshout != null)}"
    "-Dsndio=disabled"
    "-Dsolaris_output=disabled"
    "-Ddbus=enabled"
    "-Dexpat=${boolEnd (expat != null)}"
    "-Dicu=enabled"
    "-Diconv=enabled"
    "-Dpcre=${boolEnd (pcre != null)}"
    "-Dsqlite=enabled"
    "-Dyajl=${boolEnd (yajl != null)}"
    "-Dzlib=enabled"
    "-Dzeroconf=${boolString (avahi != null) "avahi" "disabled"}"
  ];

  #NIX_LDFLAGS = [ ] ++ optional (libshout != null) "-lshout";

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        pgpsigUrl = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprint = "0392 335A 7808 3894 A430  1C43 236E 8A58 C6DB 4512";
      };
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
