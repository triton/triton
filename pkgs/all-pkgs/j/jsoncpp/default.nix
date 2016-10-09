{ stdenv
, cmake
, fetchFromGitHub
, ninja
, python
}:

let
  version = "1.7.7";
in
stdenv.mkDerivation rec {
  name = "jsoncpp-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "open-source-parsers";
    repo = "jsoncpp";
    rev = version;
    sha256 = "5acdb6dda14d47422b18e7d7c73a75ee558122cea7d80feedab03af80f5c392a";
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
    description = "A simple API to manipulate JSON data in C++";
    homepage = https://github.com/open-source-parsers/jsoncpp;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
