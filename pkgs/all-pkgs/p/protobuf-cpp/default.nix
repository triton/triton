{ stdenv
, fetchurl

, zlib
}:

let
  version = "3.5.1";
in
stdenv.mkDerivation rec {
  name = "protobuf-cpp-${version}";

  src = fetchurl {
    url = "https://github.com/google/protobuf/releases/download/v${version}/${name}.tar.gz";
    sha256 = "c28dba8782da2cfea1e11c61d335958c31a9c1bc553063546af9cbe98f204092";
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
