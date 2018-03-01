{ stdenv
, autoconf
, automake
, fetchFromGitHub
, lib
, libtool
}:

let
  version = "1.19.2";
in
stdenv.mkDerivation rec {
  name = "libuv-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "libuv";
    repo = "libuv";
    rev = "v${version}";
    sha256 = "f917781191be2600ac496efc8b8ae9bc18ff6ca1fdf4120a1ef908f85a967b65";
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
