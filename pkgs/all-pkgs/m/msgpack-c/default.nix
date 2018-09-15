{ stdenv
, cmake
, fetchurl
, ninja

, boost
, zlib
}:

let
  version = "3.1.1";
in
stdenv.mkDerivation rec {
  name = "msgpack-c-${version}";

  src = fetchurl {
    url = "https://github.com/msgpack/msgpack-c/releases/download/cpp-${version}/msgpack-${version}.tar.gz";
    sha256 = "8592d12e19ac3796889b8358bc8f78df9272e6aa7a9ea1834bafd68e4073549a";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    boost
    zlib
  ];

  cmakeFlags = [
    "-DMSGPACK_CXX11=ON"
    "-DMSGPACK_BOOST=ON"
    "-DMSGPACK_BUILD_EXAMPLES=OFF"
    "-DMSGPACK_BUILD_TESTS=OFF"
  ];

  meta = with stdenv.lib; {
    description = "MessagePack implementation for C and C++";
    homepage = http://msgpack.org;
    license = licenses.asl20;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
