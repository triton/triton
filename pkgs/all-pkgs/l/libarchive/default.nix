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

let
  rev = "d9d9d1683ec875fdf7abf21e0049bf285d9f9ec1";
  date = "2017-11-02";
in
stdenv.mkDerivation rec {
  name = "libarchive-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "libarchive";
    repo = "libarchive";
    inherit rev;
    sha256 = "251d1617a2f8f65f8a0bed595f9b4abd6f283387d6296bfc413aaf4a7bae2c21";
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
