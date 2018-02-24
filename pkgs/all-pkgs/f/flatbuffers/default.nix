{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja
}:

let
  version = "1.8.0";
in
stdenv.mkDerivation {
  name = "flatbuffers-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "google";
    repo = "flatbuffers";
    rev = "v${version}";
    sha256 = "9368092e056212af3e1716bc03840032c7d2c8b4e92dc7e43a4be4e05967c5d1";
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
