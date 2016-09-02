{ stdenv
, cmake
, fetchgit
, go
, ninja
, perl

, zlib
}:

let
  version = "1.0.0";
in
stdenv.mkDerivation {
  name = "grpc-${version}";

  src = fetchgit {
    url = "https://github.com/grpc/grpc.git";
    rev = "refs/tags/v${version}";
    sha256 = "0a5h7ydvyyywpf5ifxxma8h9i0nsh2fg3k7dlsg57486mjmpbzgd";
  };

  nativeBuildInputs = [
    cmake
    go
    ninja
    perl
  ];

  buildInputs = [
    zlib
  ];

  cmakeFlags = [
    "-DgRPC_ZLIB_PROVIDER=package"
    "-DgRPC_PROTOBUF_PROVIDER=package"
    "-DgRPC_SSL_PROVIDER=package"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
