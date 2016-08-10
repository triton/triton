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
    sha256 = "9c3930b1af9dd1d091024ed18c3eaad4b8d20f7669d510a94607a877157a4e88";
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
