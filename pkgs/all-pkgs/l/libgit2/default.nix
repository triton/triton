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
  version = "0.27.4";
in
stdenv.mkDerivation {
  name = "libgit2-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "libgit2";
    repo = "libgit2";
    rev = "v${version}";
    sha256 = "3d32cf07109b6ccdb7ac411290d76cc03a45ef38a1809b9979871ed45e180f2d";
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
