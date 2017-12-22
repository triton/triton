{ stdenv
, fetchFromGitHub
, lib
, qt5

, libusb
}:

let
  rev = "b833996ae8dc08077b2c618daa392aa32517b01f";
  date = "2017-12-22";
in
stdenv.mkDerivation rec {
  name = "moolticute-${date}";

  src = fetchFromGitHub {
    version = 5;
    owner = "mooltipass";
    repo = "moolticute";
    inherit rev;
    sha256 = "c0faddadf436636343770d41d06930a0a3bdea920ec9c1b1e469536323f82971";
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
