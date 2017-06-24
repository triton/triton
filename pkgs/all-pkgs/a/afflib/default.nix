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
  version = "3.7.16";
in
stdenv.mkDerivation {
  name = "afflib-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "sshock";
    repo = "AFFLIBv3";
    rev = "v${version}";
    sha256 = "75445be21a4b6c3d0c0198f05f1305dec85f54682f40a480bb874093965974e3";
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
