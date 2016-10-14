{ stdenv
, fetchurl

, libbsd
, libressl
}:

let
  version = "0.1.11";

  fileUrls = [
    "https://kristaps.bsd.lv/acme-client/snapshots/acme-client-portable-${version}"
  ];
in
stdenv.mkDerivation rec {
  name = "acme-client-${version}";

  src = fetchurl {
    urls = map (n: "${n}.tgz") fileUrls;
    multihash = "QmcYbwZxsyp7XsDgA6bmX1rCGFLxCAipv4ckLJUWCZLozd";
    hashOutput = false;
    sha256 = "cb197820ad5dbe0f264f96f3b39ba71c295ab07ea6447632ee0f11329dbff126";
  };

  buildInputs = [
    libbsd
    libressl
  ];

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha512Urls = map (n: "${n}.sha512") fileUrls;
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
