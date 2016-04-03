{ callPackage, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "${branch}";
  branch = "3.0.1";
  sha256 = "f7f7052c120f494dd501f96becff9b5a4ae10cfbde97bc2f1e9f0fd6613a4984";
})
