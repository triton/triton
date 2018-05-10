{ stdenv
, autoconf
, automake
, fetchFromGitHub
, lib
, libtool
}:

let
  version = "1.20.3";
in
stdenv.mkDerivation rec {
  name = "libuv-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "libuv";
    repo = "libuv";
    rev = "v${version}";
    sha256 = "0b5e649f52258166a8acc7ca40a30ec21c3005587559e2d0d92ec525f1825fa2";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
