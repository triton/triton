{ stdenv
, fetchFromGitHub
, lib
, qt5

, libusb
}:

let
  rev = "1433a84b568d3ccb0424d5064e4298dd1ff8fc0f";
  date = "2018-04-19";
in
stdenv.mkDerivation rec {
  name = "moolticute-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "mooltipass";
    repo = "moolticute";
    inherit rev;
    sha256 = "67ec1a0994e4c5d6b5acb54adc12c46afbe1d2324f3e38916f2d8268728efb49";
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
