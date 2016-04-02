{ stdenv
, autoreconfHook
, fetchFromGitHub
, fetchTritonPatch
, fetchurl

, cppunit
, curl
, libsigcxx
, libtorrent
, ncurses
, openssl
, xmlrpc_c
, zlib

, colorSupport ? false
}:

with {
  inherit (stdenv.lib)
    optionals
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "rtorrent-${version}";
  version = "2016-03-10";

  src = fetchFromGitHub {
    owner = "rakshasa";
    repo = "rtorrent";
    rev = "9abcea84c7f7594ef9cc99f151467cf8b718a9c0";
    sha256 = "38cf3b10fd70a1e4daa1b8767f2e2c16bf2d820c4227dfa597b90cf2744b6720";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    cppunit
    curl
    libsigcxx
    libtorrent
    ncurses
    openssl
    xmlrpc_c
    zlib
  ];

  patches = optionals colorSupport [
    # Optional patch adds support for custom configurable colors
    # https://github.com/Chlorm/chlorm_overlay/blob/master/net-p2p/rtorrent/README.md
    (fetchTritonPatch {
      rev = "bf125346b522ba5ed532152b2cbd1971b08b35b1";
      file = "rtorrent/rtorrent-color.patch";
      sha256 = "c52434bd06853bb819ee214a1781f2dcb97ada4253fcfb5dcec10883fda1ec01";
    })
  ];

  configureFlags = [
    "--disable-debug"
    "--disable-extra-debug"
    "--disable-werror"
    "--disable-c++0x"
    "--enable-ipv6"
    "--enable-largefile"
    "--with-statvfs"
    "--with-statfs"
    (wtFlag "ncurses" (ncurses != null) null)
    (wtFlag "ncursesw" (ncurses != null) null)
    (wtFlag "xmlrpc-c" (xmlrpc_c != null) null)
  ];

  postInstall = ''
    mkdir -pv $out/share/rtorrent
    mv -v doc/rtorrent.rc $out/share/rtorrent/rtorrent.rc
  '';

  meta = with stdenv.lib; {
    description = "An ncurses client for libtorrent";
    homepage = http://libtorrent.rakshasa.no/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
