{ stdenv
, autoreconfHook
, fetchFromGitHub

, libusb
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "hidapi-0.9.0";
  
  src = fetchFromGitHub {
    version = 6;
    owner = "libusb";
    repo = "hidapi";
    rev = name;
    sha256 = "221e2768bf7e6ce306d4405eb80b5ea37e3d4f93b00f200aa0bad9df9d4cbc3a";
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
