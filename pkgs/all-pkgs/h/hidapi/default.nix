{ stdenv
, autoreconfHook
, fetchFromGitHub

, libusb
, systemd_lib
}:

stdenv.mkDerivation {
  name = "hidapi-2016-03-03";
  
  src = fetchFromGitHub {
    version = 1;
    owner = "signal11";
    repo = "hidapi";
    rev = "b5b2e1779b6cd2edda3066bbbf0921a2d6b1c3c0";
    sha256 = "5e7367baeb6967d7dea9434f08ac0c6f6f9bed9520e3e6750ea31abf9d910641";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    libusb
    systemd_lib
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
