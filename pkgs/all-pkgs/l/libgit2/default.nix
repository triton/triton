{ stdenv
, cmake
, fetchFromGitHub
, ninja

, curl
, kerberos
, libssh2
, openssl
, zlib
}:

let
  version = "0.24.3";
in
stdenv.mkDerivation {
  name = "libgit2-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "libgit2";
    repo = "libgit2";
    rev = "v${version}";
    sha256 = "83f03f946ec4c374fd38896b997abea2c526e1a9fb6b80816096d52763b194a9";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    curl
    kerberos
    libssh2
    openssl
    zlib
  ];

  cmakeFlags = [
    "-DBUILD_CLAR=OFF"
    "-DUSE_ICONV=ON"
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
