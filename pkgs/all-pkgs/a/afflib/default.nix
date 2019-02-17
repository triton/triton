{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib

, curl
, expat
, fuse_2
, ncurses
, openssl
, readline
, zlib
}:

let
  version = "3.7.18";
in
stdenv.mkDerivation {
  name = "afflib-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "sshock";
    repo = "AFFLIBv3";
    rev = "v${version}";
    sha256 = "86a800d156811a2e97fd60fc43a675e6dad7106bee3852b1ae7ae0ec048c283f";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    curl
    expat
    fuse_2
    ncurses
    openssl
    readline
    zlib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-s3"
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
