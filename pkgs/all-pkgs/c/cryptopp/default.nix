{ stdenv
, fetchurl
, lib

, unzip
}:

let
  version = "8.2.0";

  version' = lib.replaceStrings ["."] [""] version;
in
stdenv.mkDerivation rec {
  name = "cryptopp-${version}";

  src = fetchurl {
    url = "https://www.cryptopp.com/cryptopp${version'}.zip";
    multihash = "QmY71T3t7NseaVDXAoqNojnvp7BXAz2mQPueDJEKGLD4AT";
    hashOutput = false;
    sha256 = "03f0e2242e11b9d19b28d0ec5a3fa8ed5cc7b27640e6bed365744f593e858058";
  };

  nativeBuildInputs = [
    unzip
  ];

  preUnpack = ''
    mkdir -p src
    cd src
  '';

  srcRoot = ".";

  postPatch = ''
    grep -q 'LDCONF' GNUmakefile
    sed -i '/LDCONF/d' GNUmakefile
  '';

  buildFlags = [
    "dynamic"
    "libcryptopp.pc"
  ];

  installTargets = "install-lib";

  preInstall = ''
    installFlagsArray+=("PREFIX=$out")
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprint = "B8CC 1980 2062 211A 508B  2F5C CE05 86AF 1F8E 37BD";
      };
    };
  };

}
