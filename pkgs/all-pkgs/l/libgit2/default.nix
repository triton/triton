{ stdenv
, cmake
, fetchFromGitHub
, ninja

, http-parser
, kerberos
, libssh2
, openssl
, zlib
}:

let
  version = "1.0.0";
in
stdenv.mkDerivation {
  name = "libgit2-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "libgit2";
    repo = "libgit2";
    rev = "v${version}";
    sha256 = "0e2a96d2bd110712f3fb3424e2fd2e45e0c4b3fb15e3bc1e05749199a2618bb2";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    http-parser
    kerberos
    libssh2
    openssl
    zlib
  ];

  cmakeFlags = [
    "-DBUILD_CLAR=OFF"
    "-DUSE_GSSAPI=ON"
    "-DENABLE_REPRODUCIBLE_BUILDS=ON"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
