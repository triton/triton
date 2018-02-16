{ stdenv
, cmake
, fetchFromGitHub
, ninja
}:

let
  date = "2018-02-15";
  rev = "3f0cf6b62ad1eb50d8736538363d3580dd640c3e";
in
stdenv.mkDerivation rec {
  name = "googletest-${date}";

  src = fetchFromGitHub {
    version = 5;
    owner = "google";
    repo = "googletest";
    inherit rev;
    sha256 = "de94b080fb7937c84f12c99048055a3a8a81a8c4c4a6dafcce2333da2130709c";
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
