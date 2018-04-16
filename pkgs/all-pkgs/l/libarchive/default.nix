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
  rev = "6c739e0a968628063f94ecb19db3db6a5854dcde";
  date = "2018-04-13";
in
stdenv.mkDerivation rec {
  name = "libarchive-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "libarchive";
    repo = "libarchive";
    inherit rev;
    sha256 = "8e95f50ad91cb1ad8bedc61c4787511910533df5f84abb025baf82bfb58316c8";
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
