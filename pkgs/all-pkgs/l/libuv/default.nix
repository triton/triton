{ stdenv
, autoconf
, automake
, fetchFromGitHub
, libtool
}:

let
  version = "1.10.0";
in
stdenv.mkDerivation rec {
  name = "libuv-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "libuv";
    repo = "libuv";
    rev = "v${version}";
    sha256 = "21a6de696c57c7deaa538982707e06fcfcdd0eded464b774ee560503def12d60";
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
