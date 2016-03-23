{ stdenv
, autoreconfHook
, fetchFromGitHub

, mtdev
, xorg
, pixman
}:

stdenv.mkDerivation rec {
  name = "xf86-input-mtrack-${version}";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "BlueDragonX";
    repo = "xf86-input-mtrack";
    rev = "v${version}";
    sha256 = "0522p8appcal7xc96ya6jhpj1rnmcyybm2rh6jds187ipcwv7ygh";
  };

  nativeBuildInputs = [
    autoreconfHook
    xorg.utilmacros
  ];

  buildInputs = [
    mtdev
    pixman
    xorg.inputproto
    xorg.xproto
    xorg.xorgserver
  ];

  CFLAGS = "-I${pixman}/include/pixman-1";

  meta = with stdenv.lib; {
    homepage = https://github.com/BlueDragonX/xf86-input-mtrack;
    description = "An Xorg driver for multitouch trackpads";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
