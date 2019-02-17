{ stdenv
, autoconf
, automake
, fetchFromGitHub
, libtool
, which

, c-ares
, gperftools
, openssl
, protobuf-cpp
, zlib
}:

let
  version = "1.18.0";
in
stdenv.mkDerivation {
  name = "grpc-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "grpc";
    repo = "grpc";
    rev = "v${version}";
    sha256 = "b73961835e1fd9f73e896b67564d4c38a80bf05a9546455d064a4a92bb81e259";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    protobuf-cpp
    which
  ];

  buildInputs = [
    c-ares
    gperftools
    openssl
    protobuf-cpp
    zlib
  ];

  postPatch = ''
    rm -r third_party/{cares,protobuf,zlib,googletest,boringssl}
    unpackFile ${protobuf-cpp.src}
    mv -v protobuf* third_party/protobuf

    grep -q '\-Werror' Makefile
    sed -i 's, -Werror,,g' Makefile
  '';

  NIX_CFLAGS_LINK = [
    "-pthread"
  ];

  preBuild = ''
    sed -i 's,\(grpc++.*\.so\.\)6,\11,g' Makefile
    makeFlagsArray+=("prefix=$out")
  '';

  postInstall = ''
    test -e "$out"/lib/libgrpc++.so.1
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
