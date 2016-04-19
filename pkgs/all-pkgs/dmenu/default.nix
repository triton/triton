{ stdenv
, fetchurl

, freetype
, fontconfig
, xorg
, zlib
}:

stdenv.mkDerivation rec {
  name = "dmenu-4.6";

  src = fetchurl {
    url = "http://dl.suckless.org/tools/${name}.tar.gz";
    sha256 = "1cwnvamqqlgczvd5dv5rsgqbhv8kp0ddjnhmavb3q732i8028yja";
  };

  buildInputs = [
    freetype
    fontconfig
    xorg.libX11
    xorg.libXft
    xorg.libXinerama
    xorg.libXrender
    xorg.renderproto
    xorg.xproto
    zlib
  ];

  postPatch = ''
    sed -ri -e 's!\<(dmenu|stest)\>!'"$out/bin"'/&!g' dmenu_run
  '';

  preConfigure = ''
    sed -i "s@PREFIX = /usr/local@PREFIX = $out@g" config.mk
  '';

  meta = with stdenv.lib; {
    description = "Dynamic menu for X";
    homepage = http://tools.suckless.org/dmenu;
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
