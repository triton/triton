{ fetchurl
}:

{
  "stable" = rec {
    version = "1.9.0";
    src = fetchurl {
      url = "https://static.rust-lang.org/dist/rustc-1.9.0-src.tar.gz";
      allowHashOutput = true;
      sha256 = "b19b21193d7d36039debeaaa1f61cbf98787e0ce94bd85c5cbe2a59462d7cfcd";
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
