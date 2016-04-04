{ stdenv
, fetchFromGitHub
, ncurses
}:

stdenv.mkDerivation rec {
  name = "sl-${version}";
  version = "5.02";

  src = fetchFromGitHub {
    owner = "mtoyoda";
    repo = "sl";
    rev = version;
    sha256 = "8df0edee1b23cbfde9b1c7f26647f81983e10745b8a671b6b2f0eb2cc438a393";
  };

  buildInputs = [
    ncurses
  ];

  installPhase = ''
    mkdir -p $out/bin $out/share/man/man1
    cp sl $out/bin
    cp sl.1 $out/share/man/man1
  '';

  meta = with stdenv.lib; {
    homepage = http://www.tkl.iis.u-tokyo.ac.jp/~toyoda/index_e.html;
    description = "Steam Locomotive runs across your terminal when you type 'sl'";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
