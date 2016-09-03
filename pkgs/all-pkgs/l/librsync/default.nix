{ stdenv
, cmake
, fetchFromGitHub
, ninja
, perl

, bzip2
, popt
, zlib
}:

stdenv.mkDerivation rec {
  name = "librsync-${version}";
  version = "2.0.0";

  src = fetchFromGitHub {
    version = 1;
    owner = "librsync";
    repo = "librsync";
    rev = "v${version}";
    sha256 = "566991bf13ac8ad1c7510dac68b1f411e6f8e1ccd0c2ab81cbe9fa7f20d5cafa";
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
