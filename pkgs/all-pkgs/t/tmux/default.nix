{ stdenv
, fetchurl

, libevent
, libutempter
, ncurses
, utf8proc
}:

let
  version = "2.5";
in
stdenv.mkDerivation rec {
  name = "tmux-${version}";

  src = fetchurl {
    url = "https://github.com/tmux/tmux/releases/download/${version}/${name}.tar.gz";
    sha256 = "ae135ec37c1bf6b7750a84e3a35e93d91033a806943e034521c8af51b12d95df";
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
