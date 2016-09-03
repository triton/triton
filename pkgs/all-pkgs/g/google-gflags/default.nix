{ stdenv
, cmake
, fetchFromGitHub
, ninja
}:

stdenv.mkDerivation rec {
  name = "google-gflags-${version}";
  version = "2.1.2";

  src = fetchFromGitHub {
    version = 1;
    owner = "gflags";
    repo = "gflags";
    rev = "v${version}";
    sha256 = "fea4902c36a582a0559f1ce10bc7a431a76e0ea46453d17bf6f1e2ea3d9fd99e";
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
