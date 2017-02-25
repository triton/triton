{ stdenv
, cmake
, fetchzip
, ninja

, fftw_single
}:

let
  version = "3.3.3";
in
stdenv.mkDerivation rec {
  name = "eigen-${version}";

  src = fetchzip {
    version = 2;
    url = "https://bitbucket.org/eigen/eigen/get/${version}.tar.bz2";
    sha256 = "a400fe5c3c2fd1d3d56b13ee2edb42a06a21cf8efd35dc13d80d39c1cc95fe01";
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

  meta = with stdenv.lib; {
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
