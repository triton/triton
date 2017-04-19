{ stdenv
, cmake
, fetchFromGitHub
, ninja
, perl

, bzip2
, popt
, zlib
}:

let
  date = "2017-04-18";
  rev = "572f55f9b798407ad913bc3e4e26087026149028";
in
stdenv.mkDerivation rec {
  name = "librsync-${date}";

  src = fetchFromGitHub {
    version = 2;
    owner = "librsync";
    repo = "librsync";
    rev = rev;
    sha256 = "e7f90f0ebcd8ac4cf545d101cb68350ad490c6ff1067086825e2350a00395923";
  };

  nativeBuildInputs = [
    cmake
    ninja
    perl
  ];

  buildInputs = [
    bzip2
    popt
    zlib
  ];

  meta = with stdenv.lib; {
    homepage = http://librsync.sourceforge.net/;
    license = licenses.lgpl2Plus;
    description = "Implementation of the rsync remote-delta algorithm";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
