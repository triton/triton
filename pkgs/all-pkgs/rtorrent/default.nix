{ stdenv
, autoreconfHook
, fetchFromGitHub
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
    optional;
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

  patches = optional colorSupport (fetchurl {
    # Optional patch adds support for custom configurable colors
    # https://github.com/Chlorm/chlorm_overlay/blob/master/net-p2p/rtorrent/README.md
    url = "https://gist.githubusercontent.com/codyopel/a816c2993f8013b5f4d6/raw/b952b32da1dcf14c61820dfcf7df00bc8918fec4/rtorrent-color.patch";
    sha256 = "00gcl7yq6261rrfzpz2k8bd7mffwya0ifji1xqcvhfw50syk8965";
  });

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
