{ stdenv
, fetchTritonPatch
, fetchurl
, intltool
, automake
, autoconf
, libtool
, json_c
, libsndfile
, gettext
, check

# Optional Dependencies
, alsaLib ? null
, avahi ? null
, bluez ? null
, coreaudio ? null
, dbus ? null
, esound ? null
, fftw ? null
, gconf ? null
, glib ? null
, gtk3 ? null
, libasyncns ? null
, libcap ? null
, libjack2 ? null
, lirc ? null
, openssl ? null
, oss ? null
, sbc ? null
, soxr ? null
, speexdsp ? null
, systemd ? null
, udev ? null
, valgrind ? null
, webrtc-audio-processing ? null
, xorg ? null

# Database selection
, tdb ? null
, gdbm ? null

# Extra options
, prefix ? ""

# Patch sources
# Set latency_msec in module-loopback (Default: 200)
, loopbackLatencyMsec ? "200"
# Set default resampler (Default: speex-float-1)
# See `resample-method` in manpage for pulse-daemon.conf, resample-methods.nix
# or run `pulseaudio --dump-resample-methods` for possible values.
, resampleMethod ? "speex-float-1"
}:

with {
  inherit (stdenv)
    shouldUsePkg;
  inherit (stdenv.lib)
    enFlag
    otFlag
    wtFlag
    optionals
    optionalString;
  inherit (builtins.getAttr resampleMethod (import ./resample-methods.nix))
    resampleMethodString;
};

assert resampleMethodString != null;

let
  libOnly = prefix == "lib";
  ifFull =
    a:
    if libOnly then
      null
    else
      a;

  hasXlibs = xorg != null;

  optLibcap = shouldUsePkg libcap;
  hasCaps = optLibcap != null || stdenv.isFreeBSD; # Built-in on FreeBSD

  optOss = ifFull (shouldUsePkg oss);
  hasOss = optOss != null || stdenv.isFreeBSD; # Built-in on FreeBSD

  optCoreaudio = ifFull (shouldUsePkg coreaudio);
  optAlsaLib = ifFull (shouldUsePkg alsaLib);
  optEsound = ifFull (shouldUsePkg esound);
  optGlib = shouldUsePkg glib;
  optGtk3 = ifFull (shouldUsePkg gtk3);
  optGconf = ifFull (shouldUsePkg gconf);
  optAvahi = ifFull (shouldUsePkg avahi);
  optLibjack2 = ifFull (shouldUsePkg libjack2);
  optLibasyncns = shouldUsePkg libasyncns;
  optLirc = ifFull (shouldUsePkg lirc);
  optDbus = shouldUsePkg dbus;
  optSbc = ifFull (shouldUsePkg sbc);
  optBluez =
    if optDbus == null || optSbc == null then
      null
    else
      shouldUsePkg bluez;
  optUdev = ifFull (shouldUsePkg udev);
  optOpenssl = ifFull (shouldUsePkg openssl);
  optFftw = shouldUsePkg fftw;
  optSpeexdsp = shouldUsePkg speexdsp;
  optSoxr = ifFull (shouldUsePkg soxr);
  optSystemd = shouldUsePkg systemd;
  optWebrtc-audio-processing = ifFull (shouldUsePkg webrtc-audio-processing);
  hasWebrtc = ifFull (optWebrtc-audio-processing != null);

  # Pick a database to use
  databaseName = if tdb != null then "tdb" else
    if gdbm != null then "gdbm" else "simple";
  database = {
    tdb = tdb;
    gdbm = gdbm;
    simple = null;
  }.${databaseName};
in

stdenv.mkDerivation rec {
  name = "${prefix}pulseaudio-${version}";
  version = "8.0";

  src = fetchurl {
    url = "http://freedesktop.org/software/pulseaudio/releases/"
        + "pulseaudio-${version}.tar.xz";
    sha256 = "128rrlvrgb4ia3pbzipf5mi6nvrpm6zmxn5r3bynqiikhvify3k9";
  };

  nativeBuildInputs = [
    autoconf
    automake
    gettext
    intltool
    libtool
  ];

  propagatedBuildInputs = [
    optLibcap
  ];

  buildInputs = [
    json_c
    libsndfile
    check
    database
    valgrind
    optOss
    optCoreaudio
    optAlsaLib
    optEsound
    optGlib
    optGtk3
    optGconf
    optAvahi
    optLibjack2
    optLibasyncns
    optLirc
    optDbus
    optUdev
    optOpenssl
    optFftw
    optSpeexdsp
    optSoxr
    optSystemd
    optWebrtc-audio-processing
  ] ++ optionals hasXlibs (with xorg; [
    libX11
    libxcb
    libICE
    libSM
    libXtst
    xextproto
    libXi
  ]) ++ optionals (optBluez != null) [
    optBluez
    optSbc
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
      sed -e 's/DEFAULT_LATENCY_MSEC 200/DEFAULT_LATENCY_MSEC ${loopbackLatencyMsec}/' \
          -i src/modules/module-loopback.c
    '' + optionalString (resampleMethod != "speex-float-1")
    /* Allow patching default resampler */ ''
      sed -e 's/unique_jhsdjhsdf_string/${resampleMethodString}/' \
          -i src/pulsecore/resampler.c
    '';

  preConfigure =
    /* Performs and autoreconf */ ''
      export NOCONFIGURE="yes"
      patchShebangs bootstrap.sh
      ./bootstrap.sh
    '' +
    /* Move the udev rules under $(prefix). */ ''
      sed -i "src/Makefile.in" \
          -e "s|udevrulesdir[[:blank:]]*=.*$|udevrulesdir = $out/lib/udev/rules.d|g"
    '' +
    /* don't install proximity-helper as root and setuid */ ''
      sed -i "src/Makefile.in" \
          -e "s|chown root|true |" \
          -e "s|chmod r+s |true |"
    '';

  configureFlags = [
    (otFlag "localstatedir" true "/var")
    (otFlag "sysconfdir" true "/etc")
    (enFlag "atomic-arm-memory-barrier" false null)
    (enFlag "neon-opt" false null)
    (enFlag "x11" hasXlibs null)
    (wtFlag "caps" hasCaps optLibcap)
    (enFlag "tests" true null)
    "--disable-samplerate" # Deprecated
    (wtFlag "database" true databaseName)
    (enFlag "oss-output" hasOss null)
    (enFlag "oss-wrapper" true null) # Does not use OSS
    (enFlag "coreaudio-output" (optCoreaudio != null) null)
    (enFlag "alsa" (optAlsaLib != null) null)
    (enFlag "esound" (optEsound != null) null)
    (enFlag "solaris" false null)
    (enFlag "waveout" false null) # Windows Only
    (enFlag "glib2" (optGlib != null) null)
    (enFlag "gtk3" (optGtk3 != null) null)
    (enFlag "gconf" (optGconf != null) null)
    (enFlag "avahi" (optAvahi != null) null)
    (enFlag "jack" (optLibjack2 != null) null)
    (enFlag "asyncns" (optLibasyncns != null) null)
    (enFlag "tcpwrap" false null)
    (enFlag "lirc" (optLirc != null) null)
    (enFlag "dbus" (optDbus != null) null)
    (enFlag "bluez4" false null)
    (enFlag "bluez5" (optBluez != null) null)
    (enFlag "bluez5-ofono-headset" (optBluez != null) null)
    (enFlag "bluez5-native-headset" (optBluez != null) null)
    (enFlag "udev" (optUdev != null) null)
    (enFlag "hal-compat" false null)
    (enFlag "ipv6" true null)
    (enFlag "openssl" (optOpenssl != null) null)
    (wtFlag "fftw" (optFftw != null) null)
    (wtFlag "speex" (optSpeexdsp != null) null)
    (wtFlag "soxr" (optSoxr != null) null)
    (enFlag "xen" false null)
    (enFlag "gcov" false null)
    (enFlag "systemd-daemon" (optSystemd != null) null)
    (enFlag "systemd-login" (optSystemd != null) null)
    (enFlag "systemd-journal" (optSystemd != null) null)
    (enFlag "manpages" true null)
    (enFlag "webrtc-aec" hasWebrtc null)
    (enFlag "adrian-aec" true null)
    (wtFlag "system-user" true "pulse")
    (wtFlag "system-group" true "pulse")
    (wtFlag "access-group" true "audio")
    (wtFlag "systemduserunitdir" true "\${out}/lib/systemd/user")
    (wtFlag "bash-completion-dir" true
      "\${out}/share/bash-completions/completions")
  ];

  installFlags = [
    "sysconfdir=$(out)/etc"
    "pulseconfdir=$(out)/etc/pulse"
  ];

  postInstall = optionalString libOnly ''
    rm -rf $out/{bin,share,etc,lib/{pulse-*,systemd}}
    sed -i $out/lib/pulseaudio/libpulsecore-${version}.la \
      -e 's|-lltdl|-L${libtool}/lib -lltdl|'
  '';

  meta = with stdenv.lib; {
    description = "Sound server for POSIX and Win32 systems";
    homepage = http://www.pulseaudio.org/;
    licenses = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
