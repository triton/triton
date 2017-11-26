{ stdenv
, cmake
, fetchFromGitHub
, ninja
}:

let
  date = "2017-10-30";
  rev = "d175c8bf823e709d570772b038757fadf63bc632";
in
stdenv.mkDerivation rec {
  name = "googletest-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "google";
    repo = "googletest";
    inherit rev;
    sha256 = "9d354289c8cd36adb78a9cc93e12ab80169cde8568c25aa34400419ee8813c2d";
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
