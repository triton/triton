{ fetchurl }:

let
  tarballUrls = version: [
    "https://sourceware.org/elfutils/ftp/${version}/elfutils-${version}.tar.bz2"
  ];
in
rec {
  version = "0.175";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "Qmcq9iCXs2ZY5zYk2CWDXXorBFTrNrua9XaFLUpttFiaaW";
    hashOutput = false;
    sha256 = "f7ef925541ee32c6d15ae5cb27da5f119e01a5ccdbe9fe57bf836730d7b7a65b";
  };

  srcVerification = fetchurl rec {
    failEarly = true;
    urls = tarballUrls "0.175";
    inherit (src) outputHashAlgo;
    outputHash = "1f84477557ab79bdc9f9c717a50058d08620323c1e935458223a12f249c9e066";
    fullOpts = {
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "47CC 0331 081B 8BC6 D0FD  4DA0 8370 665B 5781 6A6A";
    };
  };
}
