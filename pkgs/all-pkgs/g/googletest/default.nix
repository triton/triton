{ stdenv
, cmake
, fetchFromGitHub
, ninja
}:

let
  date = "2017-12-21";
  rev = "5490beb0602eab560fa3969a4410e11d94bf12af";
in
stdenv.mkDerivation rec {
  name = "googletest-${date}";

  src = fetchFromGitHub {
    version = 5;
    owner = "google";
    repo = "googletest";
    inherit rev;
    sha256 = "f5030960de6de0f16c542d895bb930633b9c2508282995cbba861b8eb3389277";
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
