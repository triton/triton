{ stdenv
, fetchFromGitHub
, lib
, qt5

, libusb
}:

let
  rev = "aeb3e869d3bc552e8e3bb74798dddf8d6ad0fd82";
  date = "2017-10-31";
in
stdenv.mkDerivation rec {
  name = "moolticute-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "mooltipass";
    repo = "moolticute";
    inherit rev;
    sha256 = "aeb255bac16ddcb88491a0847099d5e67060128c2a678690adbb5f30fd0968bc";
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
