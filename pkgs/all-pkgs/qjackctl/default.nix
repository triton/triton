{ stdenv
, fetchurl

, alsa-lib
, dbus
, jack2_lib
, portaudio
, qt5
}:

with {
  inherit (stdenv.lib)
    enFlag
    optionals;
};

stdenv.mkDerivation rec {
  version = "0.4.1";
  name = "qjackctl-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/qjackctl/${name}.tar.gz";
    sha256 = "1ldzw84vb0x51y7r2sizx1hj4js9sr8s1v8g55nc2npmm4g4w0lq";
  };

  buildInputs = [
    alsa-lib
    dbus
    jack2_lib
    qt5.qtbase
    qt5.qttranslations
    qt5.qtx11extras
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
    (enFlag "alsa-seq" (alsa-lib != null) null)
    (enFlag "portaudio" (portaudio != null) null)
    (enFlag "dbus" (dbus != null) null)
    "--enable-xunique"
    "--disable-stacktrace"
  ];

  NIX_CFLAGS_COMPILE = optionals (portaudio != null) [
    "-I${portaudio}/include"
  ];

  NIX_LDFLAGS = optionals (portaudio != null) [
    "-L${portaudio}/lib"
  ];

  meta = with stdenv.lib; {
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
