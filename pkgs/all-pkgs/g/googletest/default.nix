{ stdenv
, cmake
, fetchFromGitHub
, ninja
}:

let
  date = "2019-02-05";
  rev = "9a502a5b14b4a6160103c1f2c64331772878d86a";
in
stdenv.mkDerivation rec {
  name = "googletest-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "google";
    repo = "googletest";
    inherit rev;
    sha256 = "e1624a1c5fc360bce390b97b3510ac62688479ea5b099380fffe536210594621";
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
