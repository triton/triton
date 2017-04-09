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
  version = "1.2.3";
in
stdenv.mkDerivation {
  name = "grpc-${version}";

  src = fetchgit {
    version = 2;
    url = "https://github.com/grpc/grpc.git";
    rev = "refs/tags/v${version}";
    sha256 = "8cc17b17eea21f3ecbcc53b08c08c6a892c168afa75bc4ff7637562ccdf32eb6";
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
