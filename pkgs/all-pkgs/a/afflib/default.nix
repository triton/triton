{ stdenv
, autoreconfHook
, fetchFromGitHub

, curl
, expat
, fuse
, ncurses
, openssl
, readline
, zlib
}:

let
  version = "3.7.4";
in
stdenv.mkDerivation {
  name = "afflib-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "simsong";
    repo = "AFFLIBv3";
    rev = "v${version}";
    sha256 = "4d917bec1749c7e587e57a5ebf41561546481b5b82f501e28c861bd192756fe4";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];
  
  buildInputs = [
    curl
    expat
    fuse
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

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
