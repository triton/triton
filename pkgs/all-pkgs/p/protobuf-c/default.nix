{ stdenv
, fetchurl

, protobuf-cpp_legacy
}:

let
  version = "1.3.0";
in
stdenv.mkDerivation rec {
  name = "protobuf-c-${version}";

  src = fetchurl {
    url = "https://github.com/protobuf-c/protobuf-c/releases/download/v${version}/${name}.tar.gz";
    sha256 = "5dc9ad7a9b889cf7c8ff6bf72215f1874a90260f60ad4f88acf21bb15d2752a1";
  };

  nativeBuildInputs = [
    protobuf-cpp_legacy
  ];

  buildInputs = [
    protobuf-cpp_legacy
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
