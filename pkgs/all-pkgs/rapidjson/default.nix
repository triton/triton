{ stdenv
, cmake
, fetchFromGitHub
, ninja
}:

stdenv.mkDerivation rec {
  name = "rapidjson-${version}";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "miloyip";
    repo = "rapidjson";
    rev = "v${version}";
    sha256 = "7ba9555701b383600d3f8a90fe06e491a085006effdf3592c0f3bb2b690f34f7";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = [
    "-DRAPIDJSON_BUILD_EXAMPLES=NO"
  ];

  meta = with stdenv.lib; {
    description = "Fast JSON parser/generator for C++";
    homepage = https://github.com/miloyip/rapidjson;
    license = with licenses; [
      bsdOrginal
      #json
      mit
    ];
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
