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
  version = "2.0.1";
in
stdenv.mkDerivation rec {
  name = "librsync-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "librsync";
    repo = "librsync";
    rev = "v${version}";
    sha256 = "4ed1c66c6b9b18f50e10288164455f0c046060f78f83565b6886a499f00cd912";
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
