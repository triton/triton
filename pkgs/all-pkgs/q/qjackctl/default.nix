{ stdenv
, fetchurl
, lib

, alsa-lib
, dbus
, jack2_lib
, libx11
, libxcb
, portaudio
, qt5
, xorgproto
}:

let
  inherit (lib)
    boolEn
    optionals;

  version = "0.5.0";
in
stdenv.mkDerivation rec {
  name = "qjackctl-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/qjackctl/qjackctl/${version}/${name}.tar.gz";
    sha256 = "9a74f33f6643bea8bf742ea54f9b40f08ed339887f076ff3068159c55d0ba853";
  };

  buildInputs = [
    alsa-lib
    dbus
    jack2_lib
    libx11
    libxcb
    qt5
    xorgproto
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
