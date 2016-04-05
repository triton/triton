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
    sha256 = "97c5262f2304843cc3edf219f89abe523da3ff9e335421280d756ca33ac9fbda";
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
