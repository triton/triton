{ fetchurl
}:

{
  "stable" = rec {
    version = "1.14.0";
    src = fetchurl {
      url = "https://static.rust-lang.org/dist/rustc-${version}-src.tar.gz";
      hashOutput = false;
      sha256 = "c790edd2e915bd01bea46122af2942108479a2fda9a6f76d1094add520ac3b6b";
    };
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "108F 6620 5EAE B0AA A8DD  5E1C 85AB 96E6 FA1B E5FE";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };
  "beta" = {
  };
  "dev" = {
  };
}
