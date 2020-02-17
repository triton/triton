{ stdenv
, fetchurl

, libevent
, libutempter
, ncurses
, utf8proc
}:

let
  version = "3.0a";
in
stdenv.mkDerivation rec {
  name = "tmux-${version}";

  src = fetchurl {
    url = "https://github.com/tmux/tmux/releases/download/${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "4ad1df28b4afa969e59c08061b45082fdc49ff512f30fc8e43217d7b0e5f8db9";
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

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = { };
    };
  };

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
