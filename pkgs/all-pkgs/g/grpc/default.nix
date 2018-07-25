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
  version = "1.13.1";
in
stdenv.mkDerivation {
  name = "grpc-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "grpc";
    repo = "grpc";
    rev = "v${version}";
    sha256 = "0863f121a158e41146ad7bde4d0e1269e019e89b5be3bd2bb6f5c33448fb745d";
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
