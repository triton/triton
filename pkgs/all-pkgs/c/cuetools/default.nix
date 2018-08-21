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
    version = 6;
    url = "https://github.com/svend/cuetools/archive/${version}.tar.gz";
    sha256 = "537b04dca0ce4b7a0c1bc4b331119625dd60f09c1b0d5a2eb525d8321af78561";
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
