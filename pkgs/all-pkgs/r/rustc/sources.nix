{ fetchurl
}:

{
  "stable" = rec {
    version = "1.13.0";
    src = fetchurl {
      url = "https://static.rust-lang.org/dist/rustc-${version}-src.tar.gz";
      hashOutput = false;
      sha256 = "ecb84775ca977a5efec14d0cad19621a155bfcbbf46e8050d18721bb1e3e5084";
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
