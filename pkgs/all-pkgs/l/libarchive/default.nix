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
  rev = "d5f35a90a4cb1eeb918213bff9d78e8b0471dc0a";
  date = "2018-10-06";
in
stdenv.mkDerivation rec {
  name = "libarchive-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "libarchive";
    repo = "libarchive";
    inherit rev;
    sha256 = "f522b220433b3994af82da66c5be8a8906d4dd6825ca5f7fae084affd1db3c61";
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
