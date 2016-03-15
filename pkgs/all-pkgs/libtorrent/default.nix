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
  version = "2016-03-10";

  src = fetchFromGitHub {
    owner = "rakshasa";
    repo = "libtorrent";
    rev = "5a3bea6602348caaabdb7a500717658137c9df2c";
    sha256 = "11i54wnqa8j1drq3i4217a4s9br93kxjddgxcw4ri4ip3qkz04kb";
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
    # Flag is not a proper boolean
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
      i686-linux
      ++ x86_64-linux;
  };
}
