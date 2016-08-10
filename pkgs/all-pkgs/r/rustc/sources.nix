{ fetchurl
}:

{
  "stable" = rec {
    version = "1.10.0";
    src = fetchurl {
      url = "https://static.rust-lang.org/dist/rustc-${version}-src.tar.gz";
      allowHashOutput = true;
      sha256 = "a4015aacf4f6d8a8239253c4da46e7abaa8584f8214d1828d2ff0a8f56176869";
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
