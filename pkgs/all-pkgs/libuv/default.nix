{ stdenv
, autoconf
, automake
, fetchFromGitHub
, libtool
}:

stdenv.mkDerivation rec {
  name = "libuv-${version}";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "libuv";
    repo = "libuv";
    rev = "v${version}";
    sha256 = "84487cc1e688e370fe19fc557199cde6d84a5363440666b3cda1ff6172c2de2d";
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
