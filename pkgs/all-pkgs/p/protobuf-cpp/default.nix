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
      version = "3.6.0";
      sha256 = "c3cab055964d554e4fd85067fe3e9eb45c9915cebcf537e97fafaa245376bce1";
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
