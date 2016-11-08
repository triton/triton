{ stdenv
, fetchurl

, libbsd
, libressl
}:

let
  version = "0.1.14";

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
    sha256 = "14aa753f65e3d2ca36a8b97d68fe36205f935eaf735b7bf6a8c5d81bc8ec04e3";
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
