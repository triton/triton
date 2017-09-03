{ stdenv
, autoreconfHook
, fetchFromGitHub

, acl
, attr
, bzip2
, e2fsprogs
, libxml2
, lz4
, lzo
, openssl
, pcre
, xz
, zlib
, zstd
}:

stdenv.mkDerivation rec {
  name = "libarchive-2017-08-30";

  src = fetchFromGitHub {
    version = 3;
    owner = "libarchive";
    repo = "libarchive";
    rev = "1f3877960058e7f7b6a79748d73276cece0d5de0";
    sha256 = "f6ee59b32b3166b0079b066c9530f9c9b4376b7ed9d07e470d1dc8ab18fe7c73";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    acl
    attr
    bzip2
    e2fsprogs
    libxml2
    lz4
    lzo
    openssl
    pcre
    xz
    zlib
    zstd
  ];

  postPatch = ''
    sed -i 's,-Werror ,,g' Makefile.am
  '';

  configureFlags = [
    "--with-zlib"
    "--with-bz2lib"
    "--with-iconv"
    "--with-lz4"
    "--with-lzma"
    "--with-lzo2"
    "--with-zstd"
    "--without-nettle"
    "--with-openssl"
    "--with-xml2"
    "--without-expat"
    "--enable-posix-regex-lib"
    "--enable-xattr"
    "--enable-acl"
  ];

  meta = with stdenv.lib; {
    description = "Multi-format archive and compression library";
    homepage = http://libarchive.org;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
