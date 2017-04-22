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
  version = "1.2.5";
in
stdenv.mkDerivation {
  name = "grpc-${version}";

  src = fetchgit {
    version = 2;
    url = "https://github.com/grpc/grpc.git";
    rev = "refs/tags/v${version}";
    sha256 = "f53d391678655145a22ee7f5f267baa0ecc269de1ba64b06cd5f94cd44dcaf03";
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
