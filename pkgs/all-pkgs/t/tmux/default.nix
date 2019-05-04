{ stdenv
, fetchurl

, libevent
, libutempter
, ncurses
, utf8proc
}:

let
  version = "2.9a";
in
stdenv.mkDerivation rec {
  name = "tmux-${version}";

  src = fetchurl {
    url = "https://github.com/tmux/tmux/releases/download/${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "839d167a4517a6bffa6b6074e89a9a8630547b2dea2086f1fad15af12ab23b25";
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
