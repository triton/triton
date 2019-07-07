{ stdenv
, fetchurl

, protobuf-cpp
}:

let
  version = "1.3.2";
in
stdenv.mkDerivation rec {
  name = "protobuf-c-${version}";

  src = fetchurl {
    url = "https://github.com/protobuf-c/protobuf-c/releases/download/v${version}/${name}.tar.gz";
    sha256 = "53f251f14c597bdb087aecf0b63630f434d73f5a10fc1ac545073597535b9e74";
  };

  nativeBuildInputs = [
    protobuf-cpp
  ];

  buildInputs = [
    protobuf-cpp
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
