{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib
, util-macros

, libpciaccess
, mtdev
, xorgproto
, xorg-server
}:

let
  version = "0.3.1";
in
stdenv.mkDerivation rec {
  name = "xf86-input-mtrack-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "BlueDragonX";
    repo = "xf86-input-mtrack";
    rev = "v${version}";
    sha256 = "26f00ed72e3c0b26878cbe0143c065d75f553e43eaca23623e9c0f2b0ab89588";
  };

  nativeBuildInputs = [
    autoreconfHook
    util-macros
  ];

  buildInputs = [
    libpciaccess
    mtdev
    xorgproto
    xorg-server
  ];

  meta = with lib; {
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
