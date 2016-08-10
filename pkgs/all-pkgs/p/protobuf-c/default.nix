{ stdenv
, fetchurl

, protobuf-cpp
}:

let
  version = "1.2.1";
in
stdenv.mkDerivation rec {
  name = "protobuf-c-${version}";

  src = fetchurl {
    url = "https://github.com/protobuf-c/protobuf-c/releases/download/v${version}/${name}.tar.gz";
    sha256 = "846eb4846f19598affdc349d817a8c4c0c68fd940303e6934725c889f16f00bd";
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
