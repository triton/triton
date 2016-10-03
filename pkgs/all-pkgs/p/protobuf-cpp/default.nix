{ stdenv
, fetchurl

, zlib
}:

let
  version = "3.1.0";
in
stdenv.mkDerivation rec {
  name = "protobuf-cpp-${version}";

  src = fetchurl {
    url = "https://github.com/google/protobuf/releases/download/v${version}/${name}.tar.gz";
    sha256 = "51ceea9957c875bdedeb1f64396b5b0f3864fe830eed6a2d9c066448373ea2d6";
  };

  buildInputs = [
    zlib
  ];

  configureFlags = [
    "--with-zlib"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
