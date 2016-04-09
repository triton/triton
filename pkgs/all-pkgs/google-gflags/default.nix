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
    sha256 = "edf80feea69f3c3500d9cd0d15d9d5839f426e3ecba5ca86640af737448164dd";
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
