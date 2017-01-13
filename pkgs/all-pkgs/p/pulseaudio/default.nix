{ stdenv
, autoconf
, automake
, fetchTritonPatch
, fetchurl
, gettext
, gnum4
, intltool
, libtool

, alsa-lib
, avahi
, bluez
, dbus
, fftw_single
, gconf
, glib
, gtk3
, json-c
, libasyncns
, libcap
, libsndfile
, jack2_lib
, lirc
, openssl
, sbc
, soxr
, speexdsp
, systemd_lib
, tdb
, webrtc-audio-processing
, xorg

, prefix ? ""

# Set latency_msec in module-loopback (Default: 200)
, loopbackLatencyMsec ? "200"
# Set default resampler (Default: speex-float-1)
# See `resample-method` in manpage for pulse-daemon.conf, resample-methods.nix
# or run `pulseaudio --dump-resample-methods` for possible values.
# NOTE: Only speex resample methods supports dynamic sample rates used by
#       some applications such as mumble.
, resampleMethod ? "speex-float-1"
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;
  inherit (builtins.getAttr resampleMethod (import ./resample-methods.nix))
    resampleMethodString;

  libOnly = prefix == "lib";

  version = "9.0";
in

assert resampleMethodString != null;

stdenv.mkDerivation rec {
  name = "${prefix}pulseaudio-${version}";

  src = fetchurl rec {
    url = "https://freedesktop.org/software/pulseaudio/releases/pulseaudio-${version}.tar.xz";
    sha1Url = "${url}.sha1";
    sha256 = "c3d3d66b827f18fbe903fe3df647013f09fc1e2191c035be1ee2d82a9e404686";
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
    glib
    dbus
    libasyncns
    libcap
    json-c
    libsndfile
    fftw_single
    tdb
    speexdsp
  ] ++ optionals (!libOnly) [
    alsa-lib
    gtk3
    gconf
    avahi
    jack2_lib
    lirc
    openssl
    soxr
    systemd_lib
    webrtc-audio-processing
    xorg.libX11
    xorg.libxcb
    xorg.libICE
    xorg.libSM
    xorg.libXtst
    xorg.xextproto
    xorg.libXi
    bluez
    sbc
  ];

  patches = [
    (fetchTritonPatch {
      rev = "eb290e5c68b1b1492561a04baf072d5b7e600cb0";
      file = "pulseaudio/caps-fix.patch";
      sha256 = "840fb49e7d581349ce687345030564f386e92a5dc05431a727a67a8ab879f756";
    })
  ] ++ optionals (resampleMethod != "speex-float-1") [
    (fetchTritonPatch {
      rev = "eb290e5c68b1b1492561a04baf072d5b7e600cb0";
      file = "pulseaudio/pulseaudio-default-resampler.patch";
      sha256 = "80947bc3c746f6b36e32b0ccbd58ce4c731c080bb682f4a315f7ea842552c867";
    })
  ];

  postPatch =
    optionalString (loopbackLatencyMsec != "200")
    /* Allow patching default latency_msec */ ''
      sed -i src/modules/module-loopback.c \
        -e 's/DEFAULT_LATENCY_MSEC 200/DEFAULT_LATENCY_MSEC ${loopbackLatencyMsec}/'  
    '' + optionalString (resampleMethod != "speex-float-1")
    /* Allow patching default resampler */ ''
      sed -i src/pulsecore/resampler.c \
        -e 's/unique_jhsdjhsdf_string/${resampleMethodString}/'
    '';

  preConfigure =
    /* Performs an autoreconf */ ''
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
    "--disable-samplerate" # Deprecated
    "--with-database=tdb"
    "--disable-esound"
    "--disable-oss-output"
    "--enable-oss-wrapper" # Does not use OSS
    "--disable-coreaudio-output"
    "--disable-solaris"
    "--disable-waveout" # Windows Only
    "--enable-glib2"
    "--enable-asyncns"
    "--disable-tcpwrap"
    "--enable-dbus"
    "--disable-bluez4"
    "--disable-hal-compat"
    "--enable-ipv6"
    "--with-fftw"
    "--with-speex"
    "--disable-xen"
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
    rm -rvf $out/{bin,share,etc,lib/{pulse-*,systemd}}
  '';

  # FIXME
  buildDirCheck = false;

  meta = with stdenv.lib; {
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
