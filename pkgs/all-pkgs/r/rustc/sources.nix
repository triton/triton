{ fetchurl
}:

{
  "stable" = rec {
    version = "1.34.1";
    src = fetchurl {
      url = "https://static.rust-lang.org/dist/rustc-${version}-src.tar.gz";
      hashOutput = false;
      sha256 = "1a231f5053fb72ad82be91f5abfd6aa60cb7898c5089e4f1ac5910a731090c51";
    };
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src) urls outputHash outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "108F 6620 5EAE B0AA A8DD  5E1C 85AB 96E6 FA1B E5FE";
      };
    };
  };
  "beta" = {
  };
  "dev" = {
  };
}
