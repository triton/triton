{ stdenv
, fetchurl
, lib

, unzip
}:

let
  version = "8.0.0";

  version' = lib.replaceStrings ["."] [""] version;
in
stdenv.mkDerivation rec {
  name = "cryptopp-${version}";

  src = fetchurl {
    url = "https://www.cryptopp.com/cryptopp${version'}.zip";
    multihash = "QmXtYRDantean7qF4nCyw96ym9mCQX1DX3Ms7DxuV38CDM";
    hashOutput = false;
    sha256 = "bbfd89b348846b920d97a1d32b88c85caf0d7bb423d4fcfab7c44349aaceb82c";
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
