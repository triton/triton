{ stdenv
, fetchurl

, alsa-lib
, dbus
, jack2_lib
, portaudio
, qt5
, xorg
}:

let
  inherit (stdenv.lib)
    enFlag
    optionals;
in

stdenv.mkDerivation rec {
  version = "0.4.2";
  name = "qjackctl-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/qjackctl/${name}.tar.gz";
    sha256 = "cf1c4aff22f8410feba9122e447b1e28c8fa2c71b12cfc0551755d351f9eaf5e";
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
    (enFlag "alsa-seq" (alsa-lib != null) null)
    (enFlag "portaudio" (portaudio != null) null)
    (enFlag "dbus" (dbus != null) null)
    "--enable-xunique"
    "--disable-stacktrace"
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
