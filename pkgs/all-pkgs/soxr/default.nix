{ stdenv
, fetchurl

, cmake
, ninja
}:

stdenv.mkDerivation rec {
  name = "soxr-0.1.2";

  src = fetchurl {
    url = "mirror://sourceforge/soxr/${name}-Source.tar.xz";
    sha256 = "0xf2w3piwz9gfr1xqyrj4k685q5dy53kq3igv663i4f4y4sg9rjl";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = [
    "-DBUILD_EXAMPLES=OFF"
    "-DBUILD_SHARED_LIBS=ON"
    "-DBUILD_TESTS=OFF"
    "-DVISIBILITY_HIDDEN=ON"
    "-DWITH_AVFFT=OFF"
    "-DWITH_DOUBLE_PRECISION=ON"
    "-DWITH_LSR_BINDINGS=ON"
    "-DWITH_OPENMP=ON"
    "-DWITH_PFFFT=ON"
    "-DWITH_SIMD=ON"
  ];

  meta = with stdenv.lib; {
    description = "The SoX audio resampler library";
    homepage = http://soxr.sourceforge.net;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
