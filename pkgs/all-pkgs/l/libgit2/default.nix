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
  version = "0.25.1";
in
stdenv.mkDerivation {
  name = "libgit2-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "libgit2";
    repo = "libgit2";
    rev = "v${version}";
    sha256 = "ea6e1d7f6c9b47882c4a41790ec14e0aa6486890e3bb06f33295b91813ee7967";
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
