{ stdenv
, fetchurl

, zlib

, channel
}:

let
  srcs = {
    "legacy" = {
      version = "3.5.1";
      sha256 = "c28dba8782da2cfea1e11c61d335958c31a9c1bc553063546af9cbe98f204092";
    };
    "latest" = {
      version = "3.6.1";
      sha256 = "b3732e471a9bb7950f090fd0457ebd2536a9ba0891b7f3785919c654fe2a2529";
    };
  };

  inherit (srcs."${channel}")
    version
    sha256;
in
stdenv.mkDerivation rec {
  name = "protobuf-cpp-${version}";

  src = fetchurl {
    url = "https://github.com/google/protobuf/releases/download/v${version}/${name}.tar.gz";
    inherit sha256;
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
