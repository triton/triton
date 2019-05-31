{ stdenv
, cmake
, fetchFromGitHub
, ninja
}:

let
  date = "2019-05-29";
  rev = "8ffb7e5c88b20a297a2e786c480556467496463b";
in
stdenv.mkDerivation rec {
  name = "googletest-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "google";
    repo = "googletest";
    inherit rev;
    sha256 = "88bca1df355015085dccccc031cca0e77b3081ef9ade8f117be1fcd667e67fe6";
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
