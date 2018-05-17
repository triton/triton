{ stdenv
, cmake
, fetchFromGitHub
, ninja

, curl
, openssl
, zlib
}:

let
  version = "1.4.51";
in
stdenv.mkDerivation {
  name = "aws-sdk-cpp-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "aws";
    repo = "aws-sdk-cpp";
    rev = version;
    sha256 = "28c7ae265312174ec6dfd3e88509ea40657afb7dcf4551bd0d3ca1a366258cb1";
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
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
