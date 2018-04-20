{ stdenv
, cmake
, fetchFromGitHub
, ninja
}:

let
  date = "2018-04-19";
  rev = "a6f06bf2fd3b832822cd4e9e554b7d47f32ec084";
in
stdenv.mkDerivation rec {
  name = "googletest-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "google";
    repo = "googletest";
    inherit rev;
    sha256 = "1382656ede7fa99def19a8c4faff8909d86f9e18fcfa512f4f2bf782376b8832";
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
