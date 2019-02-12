{ stdenv
, autoreconfHook
, fetchFromGitHub

, libusb
, systemd_lib
}:

stdenv.mkDerivation {
  name = "hidapi-2016-09-19";
  
  src = fetchFromGitHub {
    version = 6;
    owner = "signal11";
    repo = "hidapi";
    rev = "a6a622ffb680c55da0de787ff93b80280498330f";
    sha256 = "313d5fe804fbbf8187cd456865457f89a307dd70095fd7e977262025505b69ec";
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
