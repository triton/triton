{ stdenv
, buildCargo
, fetchurl

, curl
, libgit2
, openssl
}:

let
  version = "0.1.23";
in
buildCargo {
  name = "cargo-vendor-${version}";

  src = fetchurl {
    url = "https://github.com/alexcrichton/cargo-vendor/releases/download/${version}/cargo-vendor-src-${version}.tar.gz";
    sha256 = "0aa326200c6db0f1d3ce0c695d6434017d90ce3c9f843f5c09c6c4d96dfe8dc1";
  };

  buildInputs = [
    curl
    libgit2
    openssl
  ];

  LIBGIT2_SYS_USE_PKG_CONFIG = true;

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
