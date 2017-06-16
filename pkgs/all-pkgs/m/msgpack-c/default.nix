{ stdenv
, cmake
, fetchurl
, ninja

, boost
, zlib
}:

let
  version = "2.1.3";
in
stdenv.mkDerivation rec {
  name = "msgpack-c-${version}";

  src = fetchurl {
    url = "https://github.com/msgpack/msgpack-c/releases/download/cpp-${version}/msgpack-${version}.tar.gz";
    sha256 = "beaac1209f33276b5a75e7a02f8689ed44b97209cef82ba0909e06f0c45f6cae";
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
