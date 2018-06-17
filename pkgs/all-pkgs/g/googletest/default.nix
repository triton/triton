{ stdenv
, cmake
, fetchFromGitHub
, ninja
}:

let
  date = "2018-06-14";
  rev = "ba96d0b1161f540656efdaed035b3c062b60e006";
in
stdenv.mkDerivation rec {
  name = "googletest-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "google";
    repo = "googletest";
    inherit rev;
    sha256 = "e319a90f13fa19f6f4cbe36f46f7d274b53f108627adf3c3350d2f58397bd9ad";
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
