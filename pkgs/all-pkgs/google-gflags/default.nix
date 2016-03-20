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
    sha256 = "0qxvr9cyxq3px60jglkm94pq5bil8dkjjdb99l3ypqcds7iypx9w";
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
