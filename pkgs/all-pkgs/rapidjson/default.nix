{ stdenv
, fetchFromGitHub
, cmake
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

  configureFlags = [
    "-DRAPIDJSON_BUILD_EXAMPLES=NO"
  ];

  meta = with stdenv.lib; {
    license = licenses.free;
    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
    maintainers = with maintainers; [
      wkennington
    ];
  };
}
