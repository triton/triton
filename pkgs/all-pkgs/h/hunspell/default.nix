{ stdenv
, autoreconfHook
, fetchFromGitHub

, ncurses
, readline
}:

stdenv.mkDerivation rec {
  name = "hunspell-${version}";
  version = "1.4.1";

  src = fetchFromGitHub {
    version = 1;
    owner = "hunspell";
    repo = "hunspell";
    rev = "v${version}";
    sha256 = "87a69146d75c74a54f6705828b40d4d627139501d7f58ea862c2d4431f2857ad";
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
