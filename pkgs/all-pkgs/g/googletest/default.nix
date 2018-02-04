{ stdenv
, cmake
, fetchFromGitHub
, ninja
}:

let
  date = "2018-01-31";
  rev = "ea31cb15f0c2ab9f5f5b18e82311eb522989d747";
in
stdenv.mkDerivation rec {
  name = "googletest-${date}";

  src = fetchFromGitHub {
    version = 5;
    owner = "google";
    repo = "googletest";
    inherit rev;
    sha256 = "cfe7e1c8af257c2e901887170586e39359699510366e531c7887a6bff232b310";
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
