{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-07-20";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "spl";
    rev = "d2f97b2a2651d8e1a6e9e1dcb07cfe8570efcfff";
    sha256 = "4c1143175f15c4b3897e3042dff578a863984f39f7c8234d7cbccc959bc212b4";
  };

  patches = [ ./patches.patch ];
})
