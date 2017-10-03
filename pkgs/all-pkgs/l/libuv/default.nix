{ stdenv
, autoconf
, automake
, fetchFromGitHub
, libtool
}:

let
  version = "1.15.0";
in
stdenv.mkDerivation rec {
  name = "libuv-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "libuv";
    repo = "libuv";
    rev = "v${version}";
    sha256 = "4db1047143e34462ff302db1f5950f5d17ffc9092a16531e1ccfa5bc138f2fea";
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
