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
  version = "0.28.2";
in
stdenv.mkDerivation {
  name = "libgit2-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "libgit2";
    repo = "libgit2";
    rev = "v${version}";
    sha256 = "13f929324aaa843f7e759f0101e3a497797b032153401ca2cc602f70020d06b6";
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
