{ stdenv
, fetchurl
, lib

, alsa-lib
, dbus
, jack2_lib
, portaudio
, qt5
, xorg
}:

let
  inherit (lib)
    boolEn
    optionals;

  version = "0.4.4";
in
stdenv.mkDerivation rec {
  name = "qjackctl-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/qjackctl/qjackctl/${version}/${name}.tar.gz";
    sha256 = "531db2f7eca654fd8769a1281dccb54ebca57a0b2a575734d1bafc3896a46ba5";
  };

  buildInputs = [
    alsa-lib
    dbus
    jack2_lib
    qt5
    xorg.libX11
    xorg.libxcb
    xorg.xproto
  ];

  configureFlags = [
    "--disable-debug"
    "--disable-qt4"
    "--enable-qt5"
    "--enable-system-tray"
    "--enable-jack-midi"
    "--enable-jack-session"
    "--enable-jack-port-aliases"
    "--enable-jack-metadata"
    "--enable-jack-version"
    "--${boolEn (alsa-lib != null)}-alsa-seq"
    "--${boolEn (portaudio != null)}-portaudio"
    "--${boolEn (dbus != null)}-dbus"
    "--enable-xunique"
    "--disable-stacktrace"
  ];

  meta = with lib; {
    description = "Application to control the JACK sound server daemon";
    homepage = http://qjackctl.sourceforge.net/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
