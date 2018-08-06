{ stdenv
, cmake
, fetchFromGitHub
, ninja

, curl
, openssl
, zlib
}:

let
  version = "1.5.7";
in
stdenv.mkDerivation {
  name = "aws-sdk-cpp-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "aws";
    repo = "aws-sdk-cpp";
    rev = version;
    sha256 = "42c5601d62c27acdc04eadbe34ac6dac4a066dd823e7194f3c3eade431d5b5fe";
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

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
