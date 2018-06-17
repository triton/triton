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
  rev = "d7dea508d1a4d2052f7578d2e2be32162040d3a5";
  date = "2018-06-10";
in
stdenv.mkDerivation rec {
  name = "libarchive-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "libarchive";
    repo = "libarchive";
    inherit rev;
    sha256 = "ebe4cf59c1a6bb757d31452af4893fecc4e9d000c5914316f6b2932105fcdec8";
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
