{ stdenv
, fetchurl
, xorg
}:

stdenv.mkDerivation rec {
  name = "slock-1.3";

  src = fetchurl {
    url = "http://dl.suckless.org/tools/${name}.tar.gz";
    sha256 = "065xa9hl7zn0lv2f7yjxphqsa35rg6dn9hv10gys0sh4ljpa7d5s";
  };

  buildInputs = [
    xorg.libX11
    xorg.libXext
    xorg.libXrandr
    xorg.libXrender
    xorg.randrproto
    xorg.renderproto
    xorg.xproto
  ];

  preInstall = ''
    installFlagsArray+=("PREFIX=$out")
  '';

  meta = with stdenv.lib; {
    homepage = http://tools.suckless.org/slock;
    description = "Simple X display locker";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
