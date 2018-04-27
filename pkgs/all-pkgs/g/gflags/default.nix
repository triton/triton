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
    version = 6;
    owner = "gflags";
    repo = "gflags";
    rev = "v${version}";
    sha256 = "78726a75af3148ac6b782e1ea797a71d8f9b51fc2ff65df5171da9e8288a736f";
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
