{ stdenv
, cmake
, fetchFromGitHub
, ninja
, python
}:

let
  version = "1.7.6";
in
stdenv.mkDerivation rec {
  name = "jsoncpp-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "open-source-parsers";
    repo = "jsoncpp";
    rev = version;
    sha256 = "d601bf79f48f0198a49cb12f428e0a6c18956a26198bd7335d589984a50d1e3b";
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
