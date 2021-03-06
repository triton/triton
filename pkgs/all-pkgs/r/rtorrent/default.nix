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

let
  inherit (stdenv.lib)
    optionals
    wtFlag;
in

stdenv.mkDerivation rec {
  name = "rtorrent-${version}";
  version = "2016-10-10";

  src = fetchFromGitHub {
    version = 2;
    owner = "rakshasa";
    repo = "rtorrent";
    rev = "c3f6db03841c0b1e5c71fd69a6b11cf8d8e3eaa5";
    sha256 = "17a799e8fc5b4b8bef4c5d832e8f9a68264b3a11ad3914b70dd81c64c0c9af03";
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
