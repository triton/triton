{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja
}:

let
  version = "2.2.2";
in
stdenv.mkDerivation rec {
  name = "gflags-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "gflags";
    repo = "gflags";
    rev = "v${version}";
    sha256 = "374d1eae936f13ba380f64d5123e7d6ef5c69f9d06c48840182230c4abb7fcd8";
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
