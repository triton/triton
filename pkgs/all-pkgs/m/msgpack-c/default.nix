{ stdenv
, cmake
, fetchurl
, ninja

, boost
, zlib
}:

let
  version = "2.1.2";
in
stdenv.mkDerivation rec {
  name = "msgpack-c-${version}";

  src = fetchurl {
    url = "https://github.com/msgpack/msgpack-c/releases/download/cpp-${version}/msgpack-${version}.tar.gz";
    sha256 = "4f855ac251e927a478aa69e4d3087ec2d5eb62e034e3a7897c1d5d2df97b7863";
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
