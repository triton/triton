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
  version = "0.26.3";
in
stdenv.mkDerivation {
  name = "libgit2-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "libgit2";
    repo = "libgit2";
    rev = "v${version}";
    sha256 = "f1b1f0e3776122a7cd4efe20b594381c9220c5ef8b6d159db0a12f6d42ba54bb";
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
