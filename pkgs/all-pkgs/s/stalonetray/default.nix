{ stdenv
, fetchurl
, lib

, libice
, libsm
, libx11
#, libxpm
, xorg
, xproto
}:

stdenv.mkDerivation rec {
  name = "stalonetray-0.8.3";

  src = fetchurl {
    url = "mirror://sourceforge/stalonetray/stalonetray/${name}/"
      + "${name}.tar.bz2";
    sha256 = "36548a588b2d466913423245dda6ffb6313132cd0cec635a117d37b3dab5fd4c";
  };

  buildInputs = [
    libice
    libsm
    libx11
    xorg.libXpm
    xproto
  ];

  configureFlags = [
    "--enable-native-kde"
    "--disable-debug"
    "--disable-trace-events"
    "--disable-dump-win-info"
    "--enable-graceful-exit"
    "--with-x"
  ];

  meta = with lib; {
    description = "A stand-alone freedesktop.org and KDE system tray";
    homepage = http://stalonetray.sourceforge.net/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
