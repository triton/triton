{ stdenv
, fetchurl

, libevent
, libutempter
, ncurses
, utf8proc
}:

let
  version = "2.6";
in
stdenv.mkDerivation rec {
  name = "tmux-${version}";

  src = fetchurl {
    url = "https://github.com/tmux/tmux/releases/download/${version}/${name}.tar.gz";
    sha256 = "b17cd170a94d7b58c0698752e1f4f263ab6dc47425230df7e53a6435cc7cd7e8";
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
