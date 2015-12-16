{ callPackage, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "${branch}.3";
  branch = "2.8";
  sha256 = "1xnalm8wqia555rgd2b0mmnjp4qmygd5235agsiv96w3f4x9kkqv";
})
