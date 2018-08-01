{ stdenv
, fetchurl
, gettext
, gnum4
, intltool
, lib
, perl

, alsa-lib
, avahi
, bluez
, dbus
, fftw_single
, glib
, gtk3
, libasyncns
, libcap
, libice
, libsm
, libsndfile
, libtool
, jack2_lib
, libx11
, libxcb
, libxi
, libxtst
, lirc
, openssl
, sbc
, soxr
, speexdsp
, systemd_lib
, tdb
, webrtc-audio-processing
, xorgproto

, prefix ? ""

# Set latency_msec in module-loopback (Default: 200)
, loopbackLatencyMsec ? "20"
}:

let
  inherit (lib)
    optionals
    optionalString;

  libOnly = prefix == "lib";

  version = "12.2";
in
stdenv.mkDerivation rec {
  name = "${prefix}pulseaudio-${version}";

  src = fetchurl rec {
    url = "https://freedesktop.org/software/pulseaudio/releases/pulseaudio-${version}.tar.xz";
    multihash = "QmU3RWm7t7PVE9DvjZ6vdQVd2fVj2myHH2yx19KFfjtrCL";
    hashOutput = false;
    sha256 = "809668ffc296043779c984f53461c2b3987a45b7a25eb2f0a1d11d9f23ba4055";
  };

  nativeBuildInputs = [
    gettext
    gnum4
    intltool
    perl
  ];

  buildInputs = [
    dbus
    fftw_single
    glib
    libasyncns
    libcap
    libtool
    libsndfile
    speexdsp
    tdb
  ] ++ optionals (!libOnly) [
    alsa-lib
    avahi
    bluez
    gtk3
    jack2_lib
    libice
    libsm
    libx11
    libxcb
    libxi
    libxtst
    lirc
    openssl
    sbc
    soxr
    systemd_lib
    webrtc-audio-processing
    xorgproto
  ];

  postPatch = /* Allow patching default latency_msec */ ''
    grep -q 'DEFAULT_LATENCY_MSEC [0-9]\+' src/modules/module-loopback.c
    sed -i src/modules/module-loopback.c \
      -e 's/DEFAULT_LATENCY_MSEC [0-9]\+/DEFAULT_LATENCY_MSEC ${loopbackLatencyMsec}/'
  '';

  preConfigure = ''
    configureFlagsArray+=(
      "--with-systemduserunitdir=$out/lib/systemd/user"
      "--with-bash-completion-dir=$out/share/bash-completions/completions"
      "--with-udev-rules-dir=$out/lib/udev/rules.d"
    )
  '';

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--disable-atomic-arm-memory-barrier"
    "--disable-neon-opt"
    "--disable-tests"
    "--disable-samplerate"  # Deprecated
    "--with-database=tdb"
    "--disable-esound"
    "--disable-oss-output"
    "--enable-oss-wrapper"  # Does not use OSS
    "--disable-coreaudio-output"
    "--disable-solaris"
    "--disable-waveout"  # Windows
    "--enable-glib2"
    "--disable-gconf"
    "--enable-asyncns"
    "--disable-tcpwrap"
    "--enable-dbus"
    "--disable-bluez4"
    "--disable-hal-compat"
    "--enable-ipv6"
    "--with-fftw"
    "--with-speex"
    "--disable-gcov"
    "--enable-adrian-aec"
    "--with-system-user=pulse"
    "--with-system-group=pulse"
    "--with-access-group=audio"
    "--enable-memfd"
  ] ++ optionals (libOnly) [
    "--disable-x11"
    "--disable-alsa"
    "--disable-gtk3"
    "--disable-gsettings"
    "--disable-avahi"
    "--disable-jack"
    "--disable-lirc"
    "--disable-bluez5"
    "--disable-bluez5-ofono-headset"
    "--disable-bluez5-native-headset"
    "--disable-udev"
    "--disable-openssl"
    "--without-soxr"
    "--disable-manpages"
    "--disable-webrtc-aec"
    "--disable-systemd-daemon"
    "--disable-systemd-login"
    "--disable-systemd-journal"
  ] ++ optionals (!libOnly) [
    "--enable-x11"
    "--enable-alsa"
    "--enable-gtk3"
    "--enable-gsettings"
    "--enable-avahi"
    "--enable-jack"
    "--enable-lirc"
    "--enable-bluez5"
    "--enable-bluez5-ofono-headset"
    "--enable-bluez5-native-headset"
    "--enable-udev"
    "--enable-openssl"
    "--with-soxr"
    "--enable-manpages"
    "--enable-webrtc-aec"
    "--enable-systemd-daemon"
    "--enable-systemd-login"
    "--enable-systemd-journal"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "pulseconfdir=$out/etc/pulse"
    )
  '';

  postInstall = optionalString libOnly ''
    rm -rvf "$out"/{bin,share/{bash-completion,locale,zsh},etc,lib/{pulse-*,systemd},libexec}
  '';

  # FIXME
  buildDirCheck = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha256Urls = map (n: "${n}.sha256") src.urls;
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    description = "Sound server for POSIX and Win32 systems";
    homepage = http://www.pulseaudio.org/;
    licenses = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
