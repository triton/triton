{ stdenv
, autoreconfHook
, fetchgit
, texinfo

, lzo
, ncurses
, openssl
, readline
, zlib
}:

stdenv.mkDerivation rec {
  name = "tinc-1.1pre-2016-02-28";

  src = fetchgit {
    url = "git://tinc-vpn.org/tinc";
    rev = "bf50b3502a022b406424d0d03aaf7670133452b2";
    sha256 = "0v04xyyyrqjf0wiswqgzwyysfpxparxx70v22i1ybkmgj4gcxx5j";
  };

  nativeBuildInputs = [
    autoreconfHook
    texinfo
  ];

  buildInputs = [
    lzo
    ncurses
    openssl
    readline
    zlib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  meta = with stdenv.lib; {
    description = "VPN daemon with full mesh routing";
    homepage="http://www.tinc-vpn.org/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
