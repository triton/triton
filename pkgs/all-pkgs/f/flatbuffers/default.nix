{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja
}:

let
  version = "1.10.0";
in
stdenv.mkDerivation {
  name = "flatbuffers-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "google";
    repo = "flatbuffers";
    rev = "v${version}";
    sha256 = "810db89d0354ce12b3fb0c46edce6137cb28391a12cf89aea226bc12dcd57f57";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = [
    "-DFLATBUFFERS_BUILD_TESTS=OFF"
    "-DFLATBUFFERS_BUILD_SHAREDLIB=ON"
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
