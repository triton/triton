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
    optionals;
};

stdenv.mkDerivation rec {
  name = "rtorrent-${version}";
  version = "2015-09-07";

  src = fetchFromGitHub {
    owner = "rakshasa";
    repo = "rtorrent";
    rev = "62cb5a4605c0664bc522e0e0da9c72f09cf643a9";
    sha256 = "0l2kqkbfl5l7drmqdqdryq1p0fpz05aghxrqd29fs4j9bx0djnaw";
  };

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
    "--with-ncurses"
    "--with-ncursesw"
    "--with-xmlrpc-c"
  ];

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

  postInstall = ''
    mkdir -pv $out/share/rtorrent
    mv -v doc/rtorrent.rc $out/share/rtorrent/rtorrent.rc
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "An ncurses client for libtorrent";
    homepage = http://libtorrent.rakshasa.no/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
