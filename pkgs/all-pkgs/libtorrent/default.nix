{ stdenv
, autoreconfHook
, fetchFromGitHub

, cppunit
, openssl
, libsigcxx
, libtool
, zlib
}:

stdenv.mkDerivation rec {
  name = "libtorrent-${version}";
  version = "2016-03-22";

  src = fetchFromGitHub {
    owner = "rakshasa";
    repo = "libtorrent";
    rev = "ef46ca30f778057095c9ef932527d5e7a8785fad";
    sha256 = "eed36f9aa15be12d3b3593648e3e7c126d5656a8201432ec9d71eeda9ea56118";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    cppunit
    libsigcxx
    openssl
    zlib
  ];

  configureFlags = [
    "--disable-debug"
    "--disable-extra-debug"
    "--disable-werror"
    "--disable-c++0x"
    "--enable-largefile"
    "--enable-aligned"
    "--enable-interrupt-socket"
    "--enable-openssl"
    # Flag is not a boolean
    #"--disable-cyrus-rc4"
    "--enable-mincore"
    "--enable-ipv6"
    "--enable-instrumentation"
    "--with-kqueue"
    "--with-epoll"
    "--with-posix-fallocate"
    #"--with-address-space=1024mb"
    "--with-statvfs"
    "--with-statfs"
    "--with-zlib"
  ];

  meta = with stdenv.lib; {
    description = " High performance BitTorrent library for unix";
    homepage = http://libtorrent.rakshasa.no/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
