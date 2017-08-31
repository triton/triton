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
  version = "1.6.0";
in
stdenv.mkDerivation {
  name = "grpc-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "grpc";
    repo = "grpc";
    rev = "v${version}";
    sha256 = "812e371f2c53b7dd9685f00ef1100ba1f21ee3e391ac95e490378759066f80cc";
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
    sed -i 's,\(grpc++.*\.so\.\)4,\11,g' Makefile

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
