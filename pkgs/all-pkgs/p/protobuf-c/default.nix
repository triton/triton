{ stdenv
, fetchurl

, protobuf-cpp
}:

let
  version = "1.3.1";
in
stdenv.mkDerivation rec {
  name = "protobuf-c-${version}";

  src = fetchurl {
    url = "https://github.com/protobuf-c/protobuf-c/releases/download/v${version}/${name}.tar.gz";
    sha256 = "51472d3a191d6d7b425e32b612e477c06f73fe23e07f6a6a839b11808e9d2267";
  };

  nativeBuildInputs = [
    protobuf-cpp
  ];

  buildInputs = [
    protobuf-cpp
  ];

  postPatch = ''
    # Fix namespace for 3.7.0+
    grep -q 'google::protobuf::Message::Reflection' t/generated-code2/cxx-generate-packed-data.cc
    sed -i 's,google::protobuf::Message::Reflection,google::protobuf::Reflection,' t/generated-code2/cxx-generate-packed-data.cc
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
