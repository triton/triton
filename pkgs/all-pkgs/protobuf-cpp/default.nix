{ stdenv
, fetchurl

, zlib
}:

let
  version = "3.0.0-beta-3";
in
stdenv.mkDerivation rec {
  name = "protobuf-cpp-${version}";

  src = fetchurl {
    url = "https://github.com/google/protobuf/releases/download/v${version}/${name}.tar.gz";
    sha256 = "e57d49f4e4bf99a4a365c2f42467b2def6e7d0ed3d4e06ddc618c770ac8fe669";
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
