{ stdenv
, autoreconfHook
, fetchFromGitHub

, ncurses
, readline
}:

stdenv.mkDerivation rec {
  name = "hunspell-${version}";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "hunspell";
    repo = "hunspell";
    rev = "v${version}";
    sha256 = "4e0e533c084032bdb9dc2d4c51e8d9f9f179dbec3fbabd5d1cb44a6e5f260fb2";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    ncurses
    readline
  ];

  configureFlags = [
    "--with-ui"
    "--with-readline"
  ];

  meta = with stdenv.lib; {
    homepage = http://hunspell.sourceforge.net;
    description = "Spell checker";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
