{ stdenv
, cmake
, fetchFromGitHub
, ninja
}:

let
  version = "1.1.0";
in
stdenv.mkDerivation rec {
  name = "rapidjson-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "miloyip";
    repo = "rapidjson";
    rev = "v${version}";
    sha256 = "48a3645abd0cdb13f071656102fd44bcb7c20b4d489f78b87973c8c0159da149";
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
