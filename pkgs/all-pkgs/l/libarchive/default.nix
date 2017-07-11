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
, pcre
, openssl
, xz
, zlib
}:

stdenv.mkDerivation rec {
  name = "libarchive-2017-07-09";

  src = fetchFromGitHub {
    version = 3;
    owner = "libarchive";
    repo = "libarchive";
    rev = "347ac2b6adfd4bca7418d30d7278d5343fc6e25e";
    sha256 = "f00151d630a8e509703e8e207f37d3ad472f5a3385639a6550bdd6c4fb86dfcc";
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
    pcre
    openssl
    xz
    zlib
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
