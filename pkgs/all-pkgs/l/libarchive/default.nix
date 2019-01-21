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
  rev = "851adb9602f1acdb090067bb4f297cd609dfa28c";
  date = "2018-12-09";
in
stdenv.mkDerivation rec {
  name = "libarchive-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "libarchive";
    repo = "libarchive";
    inherit rev;
    sha256 = "351bb83600fa084ac6bc6731d87f9d3296e912f22073d261964d5074b1399e9b";
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
