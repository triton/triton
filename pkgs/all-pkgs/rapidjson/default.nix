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
    sha256 = "01gh5d1v8rbrcl4jdksllnpfbkmc9994yr4l3ki0f87353cy872i";
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
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
