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
  version = "1.0.1";
in
stdenv.mkDerivation {
  name = "grpc-${version}";

  src = fetchgit {
    version = 2;
    url = "https://github.com/grpc/grpc.git";
    rev = "refs/tags/v${version}";
    sha256 = "0x97dvlyaaw44b8560n2g4yxv2mv3k3v5wbiwzpzmdsswb2i9gq9";
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
