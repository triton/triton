{ stdenv
, cmake
, fetchFromGitHub
, ninja
, python
}:

let
  version = "1.7.5";
in
stdenv.mkDerivation rec {
  name = "jsoncpp-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "open-source-parsers";
    repo = "jsoncpp";
    rev = version;
    sha256 = "031cdc027931af67abdf3cc808e66b04379d30877fc476edd3ed3bc9192de7fd";
  };

  nativeBuildInputs = [
    cmake
    ninja
    python
  ];

  cmakeFlags = [
    "-DJSONCPP_LIB_BUILD_SHARED=ON"
    "-DJSONCPP_LIB_BUILD_STATIC=OFF"
    "-DJSONCPP_WITH_CMAKE_PACKAGE=ON"
  ];

  meta = with stdenv.lib; {
    homepage = https://github.com/open-source-parsers/jsoncpp;
    description = "A simple API to manipulate JSON data in C++";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
