{ stdenv
, autoconf
, automake
, fetchFromGitHub
, lib
, libtool
}:

let
  version = "1.22.0";
in
stdenv.mkDerivation rec {
  name = "libuv-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "libuv";
    repo = "libuv";
    rev = "v${version}";
    sha256 = "4dcef8b2aa5523a362390426c3960ef8c4d9782cc7fd0bbb4ab35c6931ca042b";
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
