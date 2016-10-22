{ stdenv
, fetchgit
, which

, openssl
, protobuf-cpp
, zlib
}:

let
  version = "2016-10-22";
in
stdenv.mkDerivation {
  name = "grpc-${version}";

  src = fetchgit {
    version = 2;
    url = "https://github.com/grpc/grpc.git";
    rev = "566608e275c8b4b7bb9f8f61bb4d477e9c2dabc0";
    sha256 = "0wx42jwys7bss13b2qj48dw9x9r79zz39iynn1f3y64yyj872bza";
  };

  nativeBuildInputs = [
    which
  ];

  buildInputs = [
    openssl
    protobuf-cpp
    zlib
  ];

  NIX_CFLAGS_LINK = [
    "-pthread"
    "-lprotobuf"
    "-lprotoc"
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
