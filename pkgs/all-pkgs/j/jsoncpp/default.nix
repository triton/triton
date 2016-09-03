{ stdenv
, cmake
, fetchFromGitHub
, ninja
, python
}:

stdenv.mkDerivation rec {
  name = "jsoncpp-${version}";
  version = "1.7.4";

  src = fetchFromGitHub {
    version = 1;
    owner = "open-source-parsers";
    repo = "jsoncpp";
    rev = version;
    sha256 = "1e65cec9dfe1a3f2719c71325855e4bfbddf7d8315add670ee5293741abc4397";
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
