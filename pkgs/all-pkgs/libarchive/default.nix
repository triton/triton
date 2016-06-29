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
  name = "libarchive-3.2.1";

  src = fetchurl {
    url = "http://www.libarchive.org/downloads/${name}.tar.gz";
    multihash = "QmPRAWZWdDp1TzKruFjk8rsnzyyQ5fsu8R1bipX76XPYLc";
    sha256 = "1lngng84k1kkljl74q0cdqc3s82vn2kimfm02dgm4d6m7x71mvkj";
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
