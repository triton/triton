{ fetchurl
}:

{
  "stable" = rec {
    version = "1.12.0";
    src = fetchurl {
      url = "https://static.rust-lang.org/dist/rustc-${version}-src.tar.gz";
      hashOutput = false;
      sha256 = "ac5907d6fa96c19bd5901d8d99383fb8755127571ead3d4070cce9c1fb5f337a";
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
