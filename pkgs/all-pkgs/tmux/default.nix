{ stdenv
, fetchurl

, ncurses
, libevent
}:

stdenv.mkDerivation rec {
  name = "tmux-${version}";
  version = "2.1";

  src = fetchurl {
    url = "https://github.com/tmux/tmux/releases/download/${version}/${name}.tar.gz";
    sha256 = "0xk1mylsb08sf0w597mdgj9s6hxxjvjvjd6bngpjvvxwyixlwmii";
  };

  buildInputs = [
    libevent
    ncurses
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  postInstall = ''
    mkdir -p $out/etc/bash_completion.d
    cp -v examples/bash_completion_tmux.sh $out/etc/bash_completion.d/tmux
  '';

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
