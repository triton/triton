{ stdenv
, autoreconfHook
, fetchFromGitHub

, ncurses
, openssl
, readline
}:

let
  rev = "e65a96b38d49a7b3a8bdfb28c91fc6a8ef035a3d";
  date = "2019-05-29";
in
stdenv.mkDerivation rec {
  name = "ipmitool-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "ipmitool";
    repo = "ipmitool";
    inherit rev;
    sha256 = "c1584d1bf0f289e51ff013a4b85d79a6bef1d462578200f00ebb4a8c161fe833";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    ncurses
    openssl
    readline
  ];

  postPatch = ''
    patchShebangs lib/create_pen_list
  '';

  # Remove once fixed
  configureFlags = [
    "DEFAULT_INTF=open"
  ];

  meta = with stdenv.lib; {
    description = "Command-line interface to IPMI-enabled devices";
    homepage = http://ipmitool.sourceforge.net;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
