{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "1.0.8";
  sha256 = "0ylsbzpdjk8z7pc1fr0bba0gwh3235kbd7vqd4i0pf26v4jqcj94";
})
