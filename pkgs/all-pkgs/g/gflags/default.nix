{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja
}:

let
  version = "2.2.0";
in
stdenv.mkDerivation rec {
  name = "gflags-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "gflags";
    repo = "gflags";
    rev = "v${version}";
    sha256 = "43d236421279e56eb4e86bc427b6912712a94ab33ce2618b3dc2eb5e63331432";
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

  meta = with lib; {
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
