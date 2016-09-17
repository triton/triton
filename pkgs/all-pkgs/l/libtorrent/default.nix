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
  version = "2016-09-05";

  src = fetchFromGitHub {
    version = 2;
    owner = "rakshasa";
    repo = "libtorrent";
    rev = "c97b462e706872cb317d5c9d67d8f470e30bf031";
    sha256 = "92f2aabb7e4daecee70c73a2f6ae0830b998ca16d2c88975e42e4547a328b56b";
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
