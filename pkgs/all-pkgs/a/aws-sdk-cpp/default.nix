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
  version = "1.2.13";
in
stdenv.mkDerivation {
  name = "aws-sdk-cpp-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "aws";
    repo = "aws-sdk-cpp";
    rev = version;
    sha256 = "689bea30403f5cdab16ef3149dba35d9d057745d14f18383c587cacebcf1c215";
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
