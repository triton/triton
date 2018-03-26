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
  version = "0.27.0";
in
stdenv.mkDerivation {
  name = "libgit2-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "libgit2";
    repo = "libgit2";
    rev = "v${version}";
    sha256 = "36afb828ce61758d23a5dfea54b798cbf8cd01a4626cf5d8ff6f0569f43477ff";
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
