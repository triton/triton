{ stdenv
, cmake
, fetchFromGitHub
, ninja
, python
}:

let
  version = "1.8.3";
in
stdenv.mkDerivation rec {
  name = "jsoncpp-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "open-source-parsers";
    repo = "jsoncpp";
    rev = version;
    sha256 = "717c519f06a83992ea80db04355fe7ca06556891cce45281dbeadfb6378997f9";
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
