{ stdenv
, cmake
, fetchzip
, ninja

, fftw_single
}:

let
  # Not all C++11 fixes have been backported to 3.2, use 3.3-pre
  version = "3.3-beta2";
in
stdenv.mkDerivation rec {
  name = "eigen-${version}";

  src = fetchzip {
    version = 1;
    url = "https://bitbucket.org/eigen/eigen/get/${version}.tar.bz2";
    sha256 = "d8e1576145d707f9b1094ccd2f6212bf7451aa38f9dcb49c3175cf2c8951324c";
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
