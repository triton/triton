{ stdenv
, fetchFromGitHub
, lib
, qt5

, libusb
}:

let
  rev = "1ddf2aecfb7fefcbca32f03d05afafe9d124cd02";
  date = "2018-07-30";
in
stdenv.mkDerivation rec {
  name = "moolticute-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "mooltipass";
    repo = "moolticute";
    inherit rev;
    sha256 = "6d8a852dc5687a7e937cb2e3856465c1ebe868d31d4163cde3b49544b5117bd9";
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
