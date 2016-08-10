{ stdenv
, fetchurl

, ncurses
, libevent
}:

stdenv.mkDerivation rec {
  name = "tmux-${version}";
  version = "2.2";

  src = fetchurl {
    url = "https://github.com/tmux/tmux/releases/download/${version}/${name}.tar.gz";
    sha256 = "bc28541b64f99929fe8e3ae7a02291263f3c97730781201824c0f05d7c8e19e4";
  };

  buildInputs = [
    libevent
    ncurses
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
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
