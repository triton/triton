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
  version = "3.7.13";
in
stdenv.mkDerivation {
  name = "afflib-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "sshock";
    repo = "AFFLIBv3";
    rev = "v${version}";
    sha256 = "0a39e479f8daa17f2df490df7f5624b15edfa8b3aa0188a7850d8370035f793b";
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
