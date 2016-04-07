{ stdenv
, autoconf
, automake
, fetchFromGitHub
, libtool
}:

stdenv.mkDerivation rec {
  name = "libuv-${version}";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "libuv";
    repo = "libuv";
    rev = "v${version}";
    sha256 = "7b84619e2bcbf59367439b92e02fab002d14aa4d849c8c926896c58ccfc1b140";
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
