{ callPackage, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "${branch}.4";
  branch = "2.8";
  sha256 = "13jzlwqm41bzk4plshsyxx1jz87h7jpakka35834cmc4lwv83k43";
})
