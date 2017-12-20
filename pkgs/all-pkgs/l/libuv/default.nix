{ stdenv
, autoconf
, automake
, fetchFromGitHub
, libtool
}:

let
  version = "1.18.0";
in
stdenv.mkDerivation rec {
  name = "libuv-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "libuv";
    repo = "libuv";
    rev = "v${version}";
    sha256 = "6ca0634daf0b442f1f2077c5b590c9c8d7faef9f55ad2f16ac231f959f145dfb";
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
