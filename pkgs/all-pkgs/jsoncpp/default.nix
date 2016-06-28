{ stdenv
, cmake
, fetchFromGitHub
, ninja
, python
}:

stdenv.mkDerivation rec {
  name = "jsoncpp-${version}";
  version = "1.7.3";

  src = fetchFromGitHub {
    owner = "open-source-parsers";
    repo = "jsoncpp";
    rev = version;
    sha256 = "b76245429f7bc925cb912fa81d357ae40961b43f701ad04cb939257e99bb531f";
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
