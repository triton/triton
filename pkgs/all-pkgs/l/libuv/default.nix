{ stdenv
, autoconf
, automake
, fetchFromGitHub
, lib
, libtool
}:

let
  version = "1.23.0";
in
stdenv.mkDerivation rec {
  name = "libuv-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "libuv";
    repo = "libuv";
    rev = "v${version}";
    sha256 = "ac5ad39002b738bc66dae59370a9d2d5f94ad5f6700e32e3567aa77394ffb65f";
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
