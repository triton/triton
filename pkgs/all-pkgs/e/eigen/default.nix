{ stdenv
, cmake
, fetchzip
, lib
, ninja

, fftw_single
}:

let
  version = "3.3.4";
in
stdenv.mkDerivation rec {
  name = "eigen-${version}";

  src = fetchzip {
    version = 3;
    url = "https://bitbucket.org/eigen/eigen/get/${version}.tar.bz2";
    sha256 = "3298ab3fbfc075df9ed1ee4f19ba77f11e8b847efbca720763f6484586fa2cc1";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    fftw_single
  ];

  cmakeFlags = [
    "-DEIGEN_BUILD_TESTS=ON"
    "-DEIGEN_TEST_NO_FORTRAN=ON"
    "-DEIGEN_TEST_NO_OPENGL=ON"
  ];

  meta = with lib; {
    description = "C++ template library for linear algebra";
    homepage = http://eigen.tuxfamily.org ;
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
