{ stdenv
, cmake
, fetchurl
, ninja

, zlib
}:

stdenv.mkDerivation rec {
  name = "taglib-1.11";

  src = fetchurl {
    url = "https://taglib.github.io/releases/${name}.tar.gz";
    sha256 = "ed4cabb3d970ff9a30b2620071c2b054c4347f44fc63546dbe06f97980ece288";
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
