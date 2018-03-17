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
  name = "dmenu-4.8";

  src = fetchurl {
    url = "https://dl.suckless.org/tools/${name}.tar.gz";
    multihash = "QmNxYLdEb4N1BWnBLNUmBrn292Gg3TPQiRTbSPrcCGk69w";
    sha256 = "fe615a5c3607061e2106700862e82ac62a9fa1e6a7ac3d616a9c76106476db61";
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
