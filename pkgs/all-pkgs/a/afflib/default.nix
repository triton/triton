{ stdenv
, autoreconfHook
, fetchFromGitHub

, curl
, expat
, fuse_2
, ncurses
, openssl
, readline
, zlib
}:

let
  version = "3.7.15";
in
stdenv.mkDerivation {
  name = "afflib-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "sshock";
    repo = "AFFLIBv3";
    rev = "v${version}";
    sha256 = "26f09cafbe3ea4a3cc32ffb2208a0e2b647d04749970b023ccde54d1bd47baa0";
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

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
