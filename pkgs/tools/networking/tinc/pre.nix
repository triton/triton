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
  name = "tinc-1.1pre-2016-04-10";

  src = fetchgit {
    url = "git://tinc-vpn.org/tinc";
    rev = "2a7871990bc401921b8bb9accbc6a8206d564f72";
    sha256 = "0nj5zv0n4ghl2jvm6a2ldlpsl46l1mr20xbp2kv34a4333yy1ihc";
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
