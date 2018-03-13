{ stdenv
, fetchFromGitHub
, lib
, qt5

, libusb
}:

let
  rev = "8f4950a1723aeb3abd9bacb9a631eac788bbb6c9";
  date = "2018-03-13";
in
stdenv.mkDerivation rec {
  name = "moolticute-${date}";

  src = fetchFromGitHub {
    version = 5;
    owner = "mooltipass";
    repo = "moolticute";
    inherit rev;
    sha256 = "c73003c0550181c775cdd506521b979e06550cd979929a6fc2098bc497c6042a";
  };
  
  nativeBuildInputs = [
    qt5
  ];

  buildInputs = [
    qt5
    libusb
  ];

  postPatch = ''
    sed -i "s,ExecStart=.*,ExecStart=@$out/bin/moolticuted moolticuted," \
      systemd/moolticuted.service

    sed -i 's,tests,,g' Moolticute.pro
  '';

  configurePhase = ''
    mkdir build
    cd build
    qmake ../Moolticute.pro PREFIX="$out"
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
