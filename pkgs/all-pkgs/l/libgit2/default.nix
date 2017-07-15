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
  version = "0.26.0";
in
stdenv.mkDerivation {
  name = "libgit2-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "libgit2";
    repo = "libgit2";
    rev = "v${version}";
    sha256 = "6d395de55aaed0c4f897f294b1eb4bb96c11846e4ab7e175fe173cf2ef98a710";
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
