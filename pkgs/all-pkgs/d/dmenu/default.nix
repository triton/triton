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
  name = "dmenu-4.7";

  src = fetchurl {
    url = "http://dl.suckless.org/tools/${name}.tar.gz";
    multihash = "QmfWHbjBueUn281KveLuFytjLepEBBMAGvj8YKcrfBR79Y";
    sha256 = "a75635f8dc2cbc280deecb906ad9b7594c5c31620e4a01ba30dc83984881f7b9";
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
