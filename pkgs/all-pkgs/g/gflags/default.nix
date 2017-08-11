{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja
}:

let
  version = "2.2.1";
in
stdenv.mkDerivation rec {
  name = "gflags-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "gflags";
    repo = "gflags";
    rev = "v${version}";
    sha256 = "4d1bce2f9b66629af0513b4acc9381915842e8af188af115aac0b77d71990af3";
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
