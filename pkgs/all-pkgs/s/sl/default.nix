{ stdenv
, fetchFromGitHub

, ncurses
}:

let
  rev = "923e7d7ebc5c1f009755bdeb789ac25658ccce03";
  date = "2017-04-20";
in
stdenv.mkDerivation rec {
  name = "sl-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "mtoyoda";
    repo = "sl";
    inherit rev;
    sha256 = "f162eb85752900fab27405313927bfe9266ab66529a17ad48a214b5078bd99bf";
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
