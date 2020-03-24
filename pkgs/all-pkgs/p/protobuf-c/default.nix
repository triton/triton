{ stdenv
, fetchurl

, protobuf-cpp
}:

let
  version = "1.3.3";
in
stdenv.mkDerivation rec {
  name = "protobuf-c-${version}";

  src = fetchurl {
    url = "https://github.com/protobuf-c/protobuf-c/releases/download/v${version}/${name}.tar.gz";
    sha256 = "22956606ef50c60de1fabc13a78fbc50830a0447d780467d3c519f84ad527e78";
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
