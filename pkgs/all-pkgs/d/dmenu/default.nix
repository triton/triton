{ stdenv
, fetchurl
, lib

, freetype
, fontconfig
, libx11
, libxft
, libxinerama
, libxrender
, xorgproto
, zlib
}:

stdenv.mkDerivation rec {
  name = "dmenu-4.9";

  src = fetchurl {
    url = "https://dl.suckless.org/tools/${name}.tar.gz";
    multihash = "QmWVw53Ec9iWcFZafmV4eXAFuRZWQPDH9ySeddhPXqZ8gw";
    sha256 = "b3971f4f354476a37b2afb498693649009b201550b0c7c88e866af8132b64945";
  };

  buildInputs = [
    freetype
    fontconfig
    libx11
    libxft
    libxinerama
    libxrender
    xorgproto
    zlib
  ];

  postPatch = ''
    sed -i dmenu_run \
      -re 's!\<(dmenu|dmenu_path)\>!'"$out/bin"'/&!g'
    sed -i dmenu_path \
      -re 's!\<(stest)\>!'"$out/bin"'/&!g'
  '';

  preConfigure = ''
    sed -i config.mk \
      -e "s,PREFIX = /usr/local,PREFIX = $out,g"
  '';

  meta = with lib; {
    description = "Dynamic menu for X";
    homepage = http://tools.suckless.org/dmenu;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
