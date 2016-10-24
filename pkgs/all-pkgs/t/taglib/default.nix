{ stdenv
, cmake
, fetchurl
, ninja

, zlib
}:

stdenv.mkDerivation rec {
  name = "taglib-1.11.1";

  src = fetchurl {
    url = "https://taglib.github.io/releases/${name}.tar.gz";
    sha256 = "b6d1a5a610aae6ff39d93de5efd0fdc787aa9e9dc1e7026fa4c961b26563526b";
  };
  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    zlib
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DENABLE_CCACHE=OFF"
    "-DBUILD_TESTS=OFF"
    "-DBUILD_EXAMPLES=OFF"
    "-DBUILD_BINDINGS=ON"
    "-DNO_ITUNES_HACKS=OFF"
    "-DBUILD_FRAMEWORK=OFF"
    "-DTRACE_IN_RELEASE=OFF"
  ];

  meta = with stdenv.lib; {
    description = "A library for reading/writing multimedia meta-data";
    homepage = http://developer.kde.org/~wheeler/taglib.html;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
