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
  version = "0.27.3";
in
stdenv.mkDerivation {
  name = "libgit2-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "libgit2";
    repo = "libgit2";
    rev = "v${version}";
    sha256 = "f856686bb54c914711c0024ebb51da67160eb5589ec5b96f838e871a3aef17b3";
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
