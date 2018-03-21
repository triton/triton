{ stdenv
, fetchurl

, ncurses
, readline
}:

stdenv.mkDerivation rec {
  name = "unixODBC-2.3.6";

  src = fetchurl rec {
    url = "http://www.unixodbc.org/${name}.tar.gz";
    hashOutput = false;
    multihash = "QmSz44NEYC115XEuV7szZdMcQyxMHqVTWJwSJLVdXhKuTu";
    sha256 = "88b637f647c052ecc3861a3baa275c3b503b193b6a49ff8c28b2568656d14d69";
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
