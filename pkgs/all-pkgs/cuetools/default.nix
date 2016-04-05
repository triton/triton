{ stdenv
, autoreconfHook
, bison
, fetchzip
, flex

, flac
, id3v2
, vorbis-tools
}:

stdenv.mkDerivation rec {
  name = "cuetools-${version}";
  version = "1.4.1";

  src = fetchzip {
    url = "https://github.com/svend/cuetools/archive/${version}.tar.gz";
    sha256 = "44f657ca23997fb1b281bb96258fc56f144fe7cb2a52ac02e35ab7bde592703e";
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
