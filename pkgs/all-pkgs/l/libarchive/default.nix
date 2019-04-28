{ stdenv
, cmake
, fetchFromGitHub
, ninja

, acl
, bzip2
, e2fsprogs
, libb2
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
  rev = "ba6bbc3aa4706b4af8b68a468cd2d0f45172042c";
  date = "2019-04-24";
in
stdenv.mkDerivation rec {
  name = "libarchive-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "libarchive";
    repo = "libarchive";
    inherit rev;
    sha256 = "b32bf9c4c1e871b49d6d0f7cfc3fe8b8c5291cba5772cb36487a27400cdc39d9";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    acl
    bzip2
    e2fsprogs
    libb2
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
    "-DENABLE_NETTLE=OFF"
    "-DENABLE_LZO=ON"
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
