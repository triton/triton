{ stdenv
, fetchurl
, lib
}:

let
  version = "0.12";

  tarballUrls = [
    "mirror://kernel/linux/libs/ell/ell-${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "ell-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    hashOutput = false;
    sha256 = "2dcf3e91b2070645993a3083f79e27a8668cc0c5654553c194f3386ed5652aaa";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sign") tarballUrls;
        pgpDecompress = true;
        pgpKeyFingerprint = "E932 D120 BC2A EC44 4E55  8F01 06CA 9F5D 1DCF 2659";
      };
    };
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
