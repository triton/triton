{ stdenv
, cmake
, fetchFromGitHub
, ninja

, curl
, http-parser
, kerberos
, libssh2
, openssl
, zlib
}:

let
  version = "0.27.5";
in
stdenv.mkDerivation {
  name = "libgit2-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "libgit2";
    repo = "libgit2";
    rev = "v${version}";
    sha256 = "69929abb57a7db1ca11332b51382c15bbf138a00900aa7509eea51e7d15737a6";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    curl
    http-parser
    kerberos
    libssh2
    openssl
    zlib
  ];

  cmakeFlags = [
    "-DBUILD_CLAR=OFF"
    "-DUSE_ICONV=ON"
    "-DENABLE_REPRODUCIBLE_BUILDS=ON"
    "-DUSE_GSSAPI=ON"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
