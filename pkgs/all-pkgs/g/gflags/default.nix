{ stdenv
, cmake
, fetchFromGitHub
, ninja
}:

let
  version = "2.1.2";
in
stdenv.mkDerivation rec {
  name = "gflags-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "gflags";
    repo = "gflags";
    rev = "v${version}";
    sha256 = "7564048256b5149b9591b37d3e63cfc675f0050dfc4ec661030a8edc493d68c5";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DBUILD_STATIC_LIBS=ON"
    "-DBUILD_TESTING=OFF"
  ];

  meta = with stdenv.lib; {
    description = "A C++ library that implements commandline flags processing";
    homepage = https://code.google.com/p/gflags/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
