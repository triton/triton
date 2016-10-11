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
  version = "2016-10-10";

  src = fetchFromGitHub {
    version = 2;
    owner = "rakshasa";
    repo = "libtorrent";
    rev = "4d305e387a6131c94b87c20595429389a3c55c02";
    sha256 = "113440ebecaa9def4817cdc838fddcfd7b3497ce5e5fb3f7167e2107e8245cdc";
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
