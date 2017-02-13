{ stdenv
, autoconf
, automake
, fetchgit
, libtool
, which

, openssl_1-0-2
, protobuf-cpp
, zlib
}:

let
  version = "1.1.2";
in
stdenv.mkDerivation {
  name = "grpc-${version}";

  src = fetchgit {
    version = 2;
    url = "https://github.com/grpc/grpc.git";
    rev = "refs/tags/v${version}";
    sha256 = "692c7588a95aa02902c4231eaeea01783b984aad1051f1ad083404ec6a6587f9";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    which
  ];

  buildInputs = [
    openssl_1-0-2
    zlib
  ];

  NIX_CFLAGS_LINK = [
    "-pthread"
  ];

  preBuild = ''
    makeFlagsArray+=("prefix=$out")
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
