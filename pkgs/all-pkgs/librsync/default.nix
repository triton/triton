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
    owner = "librsync";
    repo = "librsync";
    rev = "v${version}";
    sha256 = "0yad7nkw6d8j824qkxrj008ak2wq6yw5p894sbhr35yc1wr5mki6";
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
