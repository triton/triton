{ stdenv
, fetchurl

, ncurses
, readline
}:

stdenv.mkDerivation rec {
  name = "unixODBC-2.3.7";

  src = fetchurl rec {
    url = "http://www.unixodbc.org/${name}.tar.gz";
    multihash = "QmcFs1e577AbkmRSUqjMqw9FwQ6PY9xDqeQ89g2N56bcVx";
    hashOutput = false;
    sha256 = "45f169ba1f454a72b8fcbb82abd832630a3bf93baa84731cf2949f449e1e3e77";
  };

  buildInputs = [
    ncurses
    readline
  ];

  configureFlags = [
    "--disable-gui"
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  passthru = {
    srcVerification = fetchurl {
      md5Url = map (n: "${n}.md5") src.urls;
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
