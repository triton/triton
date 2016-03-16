{ callPackage, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "${branch}.1";
  branch = "2.0";
  multihash = "QmR3n6s9qLNzX1Dk3t422xczJSryUU78wFfRZCcdJC5Yzx";
  sha256 = "1c2xc3nl2mg511b63rk7hrckmy14681p1m44mzw3n1fyqnjm0b0z";
})
