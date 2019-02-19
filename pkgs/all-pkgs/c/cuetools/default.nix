{ stdenv
, autoreconfHook
, bison
, fetchFromGitHub
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

  src = fetchFromGitHub {
    version = 6;
    owner = "svend";
    repo = "cuetools";
    rev = "${version}";
    sha256 = "e48cb9275a0ff8a6cd23f0f735c64aadcf812586e381c448f72101871868a8da";
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
