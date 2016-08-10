{ stdenv
, autoreconfHook
, fetchFromGitHub

, mtdev
, xorg
}:

stdenv.mkDerivation rec {
  name = "xf86-input-mtrack-${version}";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "BlueDragonX";
    repo = "xf86-input-mtrack";
    rev = "v${version}";
    sha256 = "507605b2c69b630d0c7cec77e1da504ef97af30c595ef8fa4819c53cb0e0e960";
  };

  nativeBuildInputs = [
    autoreconfHook
    xorg.utilmacros
  ];

  buildInputs = [
    mtdev
    xorg.inputproto
    xorg.pixman
    xorg.xproto
    xorg.xorgserver
  ];

  CFLAGS = "-I${xorg.pixman}/include/pixman-1";

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
