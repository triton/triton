{ stdenv
, autoconf
, automake
, fetchFromGitHub
, libtool
}:

let
  version = "1.14.1";
in
stdenv.mkDerivation rec {
  name = "libuv-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "libuv";
    repo = "libuv";
    rev = "v${version}";
    sha256 = "fdc06cbf846c7d2674c8e306c98cb8e4d513527a9bc6ab732fac11ffa2a8d41f";
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
