{ fetchurl
}:

{
  "stable" = rec {
    version = "1.11.0";
    src = fetchurl {
      url = "https://static.rust-lang.org/dist/rustc-${version}-src.tar.gz";
      hashOutput = false;
      sha256 = "3685034a78e70637bdfa3117619f759f2481002fd9abbc78cc0f737c9974de6a";
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
