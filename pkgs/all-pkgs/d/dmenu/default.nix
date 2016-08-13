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
    sed -i dmenu_run \
      -i dmenu_path \
      -re 's!\<(dmenu|dmenu_run|dmenu_path|stest)\>!'"$out/bin"'/&!g'
  '';

  preConfigure = ''
    sed -i config.mk \
      -e "s,PREFIX = /usr/local,PREFIX = $out,g"
  '';

  meta = with stdenv.lib; {
    description = "Dynamic menu for X";
    homepage = http://tools.suckless.org/dmenu;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
