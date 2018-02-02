{ stdenv
, fetchFromGitHub
, lib
, qt5

, libusb
}:

let
  rev = "78d4e20648354a13829aeab91b856d8ed1bdf733";
  date = "2018-02-01";
in
stdenv.mkDerivation rec {
  name = "moolticute-${date}";

  src = fetchFromGitHub {
    version = 5;
    owner = "mooltipass";
    repo = "moolticute";
    inherit rev;
    sha256 = "ba6d1d766b4fb446fa9a82563e505913f548e5192be3992735c1dcde7413747c";
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
