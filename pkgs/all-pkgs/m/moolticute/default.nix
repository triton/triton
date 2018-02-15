{ stdenv
, fetchFromGitHub
, lib
, qt5

, libusb
}:

let
  rev = "23ed9bd1fd90d6263c2b7d4b08019d94f1f6e79a";
  date = "2018-02-12";
in
stdenv.mkDerivation rec {
  name = "moolticute-${date}";

  src = fetchFromGitHub {
    version = 5;
    owner = "mooltipass";
    repo = "moolticute";
    inherit rev;
    sha256 = "a229dfc4bfa36228103024a0bbc416cef4669a11c48019a7fb9198c91c1bf6e5";
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
