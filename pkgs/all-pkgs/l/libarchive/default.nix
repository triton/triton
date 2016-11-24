{ stdenv
, fetchurl

, acl
, attr
, bzip2
, e2fsprogs
, libxml2
, lz4
, lzo
, pcre
, openssl
, xz
, zlib
}:

stdenv.mkDerivation rec {
  name = "libarchive-3.2.2";

  src = fetchurl {
    url = "http://www.libarchive.org/downloads/${name}.tar.gz";
    multihash = "QmXxhKX2o7UyYNRbEvwaj3JxRhBH2Wya62Pff2dCC4NN3c";
    sha256 = "691c194ee132d1f0f7a42541f091db811bc2e56f7107e9121be2bc8c04f1060f";
  };

  buildInputs = [
    acl
    attr
    bzip2
    e2fsprogs
    libxml2
    lz4
    lzo
    pcre
    openssl
    xz
    zlib
  ];

  configureFlags = [
    "--with-zlib"
    "--with-bz2lib"
    "--without-lzmadec"
    "--with-iconv"
    "--with-lz4"
    "--with-lzma"
    "--with-lzo2"
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
