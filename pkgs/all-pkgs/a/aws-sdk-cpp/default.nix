{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja

, curl
, openssl
, zlib
}:

let
  version = "1.6.27";
in
stdenv.mkDerivation {
  name = "aws-sdk-cpp-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "aws";
    repo = "aws-sdk-cpp";
    rev = version;
    sha256 = "e1edb2b78f9472c2488a06216efa21a6de6f4da55aea83573d71b870b639295e";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    curl
    openssl
    zlib
  ];

  cmakeFlags = [
    "-DENABLE_TESTING=OFF"
    "-DBUILD_ONLY=s3"
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
