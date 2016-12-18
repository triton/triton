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
  version = "1.0.41";
in
stdenv.mkDerivation {
  name = "aws-sdk-cpp-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "aws";
    repo = "aws-sdk-cpp";
    rev = version;
    sha256 = "a55f922a9128d184bfd2350821838027b1423d86b8e860d0ae67a495f98cab11";
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
