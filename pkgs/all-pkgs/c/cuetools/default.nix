{ stdenv
, autoreconfHook
, bison
, fetchzip
, flex

, flac
, id3v2
, vorbis-tools
}:

let
  version = "1.4.1";
in
stdenv.mkDerivation rec {
  name = "cuetools-${version}";

  src = fetchzip {
    version = 1;
    url = "https://github.com/svend/cuetools/archive/${version}.tar.gz";
    sha256 = "7ecf7d2775e97f69d49d65a340604850db3dbbd042b753fb90ebbc428f0cc55d";
  };

  nativeBuildInputs = [
    autoreconfHook
    bison
    flex
  ];

  buildInputs = [
    flac
    id3v2
    vorbis-tools
  ];

  meta = with stdenv.lib; {
    description = "A set of utilities for working with cue and toc files";
    homepage = https://github.com/svend/cuetools;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
