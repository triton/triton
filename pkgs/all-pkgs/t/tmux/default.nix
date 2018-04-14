{ stdenv
, fetchurl

, libevent
, libutempter
, ncurses
, utf8proc
}:

let
  version = "2.7";
in
stdenv.mkDerivation rec {
  name = "tmux-${version}";

  src = fetchurl {
    url = "https://github.com/tmux/tmux/releases/download/${version}/${name}.tar.gz";
    sha256 = "9ded7d100313f6bc5a87404a4048b3745d61f2332f99ec1400a7c4ed9485d452";
  };

  buildInputs = [
    libevent
    libutempter
    ncurses
    utf8proc
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"

    "--enable-utempter"
    "--enable-utf8proc"
  ];

  meta = with stdenv.lib; {
    homepage = http://tmux.github.io/;
    description = "Terminal multiplexer";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
