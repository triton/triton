{ stdenv
, fetchFromGitHub
, lib
, qt5

, libusb
}:

let
  rev = "ecbb2fe6cb9283b437435e4b9146a9769cbf5f8f";
  date = "2017-12-29";
in
stdenv.mkDerivation rec {
  name = "moolticute-${date}";

  src = fetchFromGitHub {
    version = 5;
    owner = "mooltipass";
    repo = "moolticute";
    inherit rev;
    sha256 = "e33e6a26ca61bcb693a04c9819be0e175e24b6853fdd3595d7999f0839f0ed84";
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
