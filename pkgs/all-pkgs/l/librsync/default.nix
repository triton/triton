{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja
, perl

, bzip2
, popt
, zlib
}:

let
  version = "2.0.2";
in
stdenv.mkDerivation rec {
  name = "librsync-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "librsync";
    repo = "librsync";
    rev = "v${version}";
    sha256 = "8b487cd533c5c8a2f7a0668dddf3b36bff6bbbdb47ebfcf7f69d9f2fd9a77837";
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

  meta = with lib; {
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
