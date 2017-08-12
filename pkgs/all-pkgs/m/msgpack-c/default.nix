{ stdenv
, cmake
, fetchurl
, ninja

, boost
, zlib
}:

let
  version = "2.1.5";
in
stdenv.mkDerivation rec {
  name = "msgpack-c-${version}";

  src = fetchurl {
    url = "https://github.com/msgpack/msgpack-c/releases/download/cpp-${version}/msgpack-${version}.tar.gz";
    sha256 = "6126375af9b204611b9d9f154929f4f747e4599e6ae8443b337915dcf2899d2b";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    boost
    zlib
  ];

  postPatch = ''
    sed -i 's, -Werror,,g' CMakeLists.txt
  '';

  cmakeFlags = [
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
