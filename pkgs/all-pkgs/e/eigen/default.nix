{ stdenv
, cmake
, fetchzip
, ninja

, fftw_single
}:

let
  version = "3.3.0";
in
stdenv.mkDerivation rec {
  name = "eigen-${version}";

  src = fetchzip {
    version = 2;
    url = "https://bitbucket.org/eigen/eigen/get/${version}.tar.bz2";
    sha256 = "be6e391061a81074be67f5eb2bcc993d3b9187592a93c9f33b83a0d9ec79cb65";
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
