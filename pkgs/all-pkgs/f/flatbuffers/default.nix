{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja
}:

let
  version = "1.9.0";
in
stdenv.mkDerivation {
  name = "flatbuffers-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "google";
    repo = "flatbuffers";
    rev = "v${version}";
    sha256 = "060cf9317d187cc2228835cb81d7e06acdc4bf635d9c9d19a7547567f1fbcfc3";
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
