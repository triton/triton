{ stdenv
, cmake
, fetchFromGitHub
, ninja

, curl
, openssl
, util-linux_lib
, zlib
}:

let
  version = "1.0.22";
in
stdenv.mkDerivation {
  name = "aws-sdk-cpp-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "aws";
    repo = "aws-sdk-cpp";
    rev = version;
    sha256 = "a54aa8236ed48c4f3c8a6098c4ea3e98425a1b020839f88d455716f1b2b9764a";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    curl
    openssl
    util-linux_lib
    zlib
  ];

  cmakeFlags = [
    "-DENABLE_TESTING=OFF"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
