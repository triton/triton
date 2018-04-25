{ stdenv
, autoconf
, automake
, fetchFromGitHub
, lib
, libtool
}:

let
  version = "1.20.2";
in
stdenv.mkDerivation rec {
  name = "libuv-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "libuv";
    repo = "libuv";
    rev = "v${version}";
    sha256 = "2b73c3b050dd39d85fada751c9530a7273340b57bab77826dacde77ade921a40";
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
