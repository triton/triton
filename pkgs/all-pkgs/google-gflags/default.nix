{ stdenv
, cmake
, fetchFromGitHub
, ninja
}:

stdenv.mkDerivation rec {
  name = "google-gflags-${version}";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "gflags";
    repo = "gflags";
    rev = "v${version}";
    sha256 = "42f3d1eeb55814f1ebe49d5e96d39a18b87555534b693cf95d19545b4909cbd7";
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
