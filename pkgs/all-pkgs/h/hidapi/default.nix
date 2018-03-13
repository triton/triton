{ stdenv
, autoreconfHook
, fetchFromGitHub

, libusb
, systemd_lib
}:

stdenv.mkDerivation {
  name = "hidapi-2016-09-19";
  
  src = fetchFromGitHub {
    version = 5;
    owner = "signal11";
    repo = "hidapi";
    rev = "a6a622ffb680c55da0de787ff93b80280498330f";
    sha256 = "34568bf58cd34ef8809058d706ecbb295cdb9e31f08e02b2953cd77545340092";
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
