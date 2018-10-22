{ stdenv
, cmake
, fetchFromGitHub
, ninja
}:

let
  date = "2018-10-22";
  rev = "82987067d8cc6ee034abd18a78bd444cb41fd2c5";
in
stdenv.mkDerivation rec {
  name = "googletest-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "google";
    repo = "googletest";
    inherit rev;
    sha256 = "b1060a56b8129c062ffcf123af2943ec6cba9f943a712e6c16e6ab771910a592";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DBUILD_GTEST=ON"
    "-DBUILD_GMOCK=ON"
  ];

  meta = with stdenv.lib; {
    description = "Google C++ Testing Framework";
    homepage = https://github.com/google/googletest;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
