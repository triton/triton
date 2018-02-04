{ stdenv
, cmake
, fetchFromGitHub
, ninja

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
  rev = "77d26b08314c4e904eb36d8bfc3ce88d5deb32d7";
  date = "2018-01-28";
in
stdenv.mkDerivation rec {
  name = "libarchive-${date}";

  src = fetchFromGitHub {
    version = 5;
    owner = "libarchive";
    repo = "libarchive";
    inherit rev;
    sha256 = "61011d74cad2d4685d0fe954b6e0d82f86e70ee54c9069b3eed964c3f917ca48";
  };

  nativeBuildInputs = [
    cmake
    ninja
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

  cmakeFlags = [
    "-DENABLE_LZO=yes"
    "-DPOSIX_REGEX_LIB=LIBPCREPOSIX"
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
