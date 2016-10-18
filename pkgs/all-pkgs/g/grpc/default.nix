{ stdenv
, cmake
, fetchgit
, go
, ninja
, perl

, openssl
, protobuf-cpp
, zlib
}:

let
  version = "2016-10-17";
in
stdenv.mkDerivation {
  name = "grpc-${version}";

  src = fetchgit {
    version = 2;
    url = "https://github.com/grpc/grpc.git";
    rev = "15586f27fa21a497cb3a4ba4d3ca5d3a381127f0";
    sha256 = "1yw8f46r6zg2664qryz8ijki1lqmyp0v019sym8a8z3ja7gk5mqx";
  };

  nativeBuildInputs = [
    cmake
    go
    ninja
    perl
  ];

  buildInputs = [
    openssl
    protobuf-cpp
    zlib
  ];

  # Don't vendor packages we have
  postPatch = ''
    sed -i 's,PROVIDER "module",PROVIDER "package",g' CMakeLists.txt
  '';

  NIX_CFLAGS_LINK = [
    "-pthread"
    "-lprotobuf"
    "-lprotoc"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
