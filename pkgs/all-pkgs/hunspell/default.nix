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
    owner = "hunspell";
    repo = "hunspell";
    rev = "v${version}";
    sha256 = "26595c2ba3270ecb7977cfb8f107493844be89c29f066b8d9bf081aabf10d9ad";
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
