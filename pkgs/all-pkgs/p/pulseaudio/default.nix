{ stdenv
, autoconf
, automake
, fetchTritonPatch
, fetchurl
, gettext
, gnum4
, intltool
, lib
, libtool

, alsa-lib
, avahi
, bluez
, dbus
, fftw_single
, gconf
, glib
, gtk3
, libasyncns
, libcap
, libice
, libsm
, libsndfile
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

  version = "11.1";
in
stdenv.mkDerivation rec {
  name = "${prefix}pulseaudio-${version}";

  src = fetchurl rec {
    url = "https://freedesktop.org/software/pulseaudio/releases/pulseaudio-${version}.tar.xz";
    multihash = "QmNWwFxdeBJdZekotdku4oxghNT6V2YK6dSwBwfvxHmzH4";
    hashOutput = false;
    sha256 = "f2521c525a77166189e3cb9169f75c2ee2b82fa3fcf9476024fbc2c3a6c9cd9e";
  };

  nativeBuildInputs = [
    autoconf
    automake
    gettext
    gnum4
    intltool
    libtool
  ];

  buildInputs = [
    dbus
    fftw_single
    glib
    libasyncns
    libcap
    libsndfile
    speexdsp
    tdb
  ] ++ optionals (!libOnly) [
    alsa-lib
    avahi
    bluez
    gconf
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

  patches = [
    (fetchTritonPatch {
      rev = "eb290e5c68b1b1492561a04baf072d5b7e600cb0";
      file = "pulseaudio/caps-fix.patch";
      sha256 = "840fb49e7d581349ce687345030564f386e92a5dc05431a727a67a8ab879f756";
    })
  ];

  postPatch = optionalString (loopbackLatencyMsec != "200")
      /* Allow patching default latency_msec */ ''
    sed -i src/modules/module-loopback.c \
      -e 's/DEFAULT_LATENCY_MSEC 200/DEFAULT_LATENCY_MSEC ${loopbackLatencyMsec}/'
  '';

  preConfigure = /* autoreconf */ ''
    export NOCONFIGURE="yes"
    patchShebangs bootstrap.sh
    ./bootstrap.sh
  '' + /* Move the udev rules under $(prefix). */ ''
    sed -i "src/Makefile.in" \
      -e "s|udevrulesdir[[:blank:]]*=.*$|udevrulesdir = $out/lib/udev/rules.d|g"
  '' + /* don't install proximity-helper as root and setuid */ ''
    sed -i "src/Makefile.in" \
      -e "s|chown root|true |" \
      -e "s|chmod r+s |true |"
  '' + ''
    configureFlagsArray+=(
      "--with-systemduserunitdir=$out/lib/systemd/user"
      "--with-bash-completion-dir=$out/share/bash-completions/completions"
    )
  '';

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--disable-atomic-arm-memory-barrier"
    "--disable-neon-opt"
    "--with-caps=${libcap}"
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
    "--disable-gconf"
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
    "--enable-gconf"
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
    rm -rvf $out/{bin,share/{bash-completion,locale,zsh},etc,lib/{pulse-*,systemd}}
  '';

  # FIXME
  buildDirCheck = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha1Urls = map (n: "${n}.sha1") src.urls;
      md5Urls = map (n: "${n}.md5") src.urls;
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
