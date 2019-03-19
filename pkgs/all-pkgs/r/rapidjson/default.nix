{ stdenv
, cmake
, fetchFromGitHub
, ninja
}:

let
  rev = "67a17cfdbc25ff1fc8d01714be87e242b03a4cc9";
  date = "2018-03-19";
in
stdenv.mkDerivation rec {
  name = "rapidjson-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "miloyip";
    repo = "rapidjson";
    inherit rev;
    sha256 = "22a04ec8f6f2e235110d369b7e638000fc19dcce9174ae716b85971aa4c9c6e8";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = [
    "-DRAPIDJSON_BUILD_DOC=OFF"
    "-DRAPIDJSON_BUILD_EXAMPLES=OFF"
    "-DRAPIDJSON_BUILD_TESTS=OFF"
  ];

  meta = with stdenv.lib; {
    description = "Fast JSON parser/generator for C++";
    homepage = https://github.com/miloyip/rapidjson;
    license = with licenses; [
      bsd3
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
