{ stdenv
, fetchFromGitHub
, lib
, qt5

, libusb
}:

let
  rev = "b65d5d7240b6ad28862a5e13c2e0202075159b94";
  date = "2018-03-19";
in
stdenv.mkDerivation rec {
  name = "moolticute-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "mooltipass";
    repo = "moolticute";
    inherit rev;
    sha256 = "fd0919e19066e9fb326dddf69319aac579a24f5b478986c586d7a0e91c271c3f";
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
