{ stdenv
, autoconf
, automake
, fetchFromGitHub
, libtool
}:

let
  version = "1.13.1";
in
stdenv.mkDerivation rec {
  name = "libuv-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "libuv";
    repo = "libuv";
    rev = "v${version}";
    sha256 = "0b2d39a724b9ca61d7754a9a55f132b8bfc59769dc42d6b35175ecdcfcc46932";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
