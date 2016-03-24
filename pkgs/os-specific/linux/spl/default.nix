{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "0.6.5.6";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "spl";
    rev = "spl-${version}";
    sha256 = "08lbfwsd368sk7dgydabzkyyn2l2n82ifcqakra3xknwgg1ka9bn";
  };

  patches = [ ./patches.patch ];
})
