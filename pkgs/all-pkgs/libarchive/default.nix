{ stdenv
, fetchTritonPatch
, fetchurl

, acl
, attr
, bzip2
, e2fsprogs
, libxml2
, lzo
, pcre
, openssl
, xz
, zlib
}:

stdenv.mkDerivation rec {
  name = "libarchive-3.1.2";

  src = fetchurl {
    urls = [
      "http://pkgs.fedoraproject.org/repo/pkgs/libarchive/libarchive-3.1.2.tar.gz/efad5a503f66329bb9d2f4308b5de98a/${name}.tar.gz"
      "${meta.homepage}/downloads/${name}.tar.gz"
    ];
    sha256 = "0pixqnrcf35dnqgv0lp7qlcw7k13620qkhgxr288v7p4iz6ym1zb";
  };

  patches = [
    (fetchTritonPatch {
      rev = "a466d5e179e575b8560a8797e9ef879168a861ed";
      file = "libarchive/CVE-2013-0211.patch";
      sha256 = "05f0320970ee148e102a25ef955afaaf285fd02c76b8835757cffbc1f1b408c7";
    })
    (fetchTritonPatch {
      rev = "a466d5e179e575b8560a8797e9ef879168a861ed";
      file = "libarchive/CVE-2015-2304.patch";
      sha256 = "5a862586b4684d819add1df9d747bc47f9a4f2fecd069175bf00f6927c9633bf";
    })
    (fetchTritonPatch {
      rev = "182777a92c9373d4679204b64b72f7d2176345ec";
      file = "libarchive/CVE-2016-1541.patch";
      sha256 = "a64f1c3e5e42adaa7f8bf9beebe094e1ce0d0a7ddc073c48a761e74c4a630848";
    })
  ];

  buildInputs = [
    acl
    attr
    bzip2
    e2fsprogs
    libxml2
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
    "--with-lzma"
    "--with-lzo2"
    "--without-nettle"
    "--with-openssl"
    "--with-libxml2"
    "--without-expat"
    "--with-posix-regex-lib"
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
      i686-linux
      ++ x86_64-linux;
  };
}
