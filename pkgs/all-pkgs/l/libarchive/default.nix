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
  rev = "4bc5892128a042780f167ac35aa72f63c426f3b7";
  date = "2019-01-30";
in
stdenv.mkDerivation rec {
  name = "libarchive-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "libarchive";
    repo = "libarchive";
    inherit rev;
    sha256 = "fa5187aa8a197525e074ae7af5a9605dc52a0e54ddf57275996d5d8e31b30d57";
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
