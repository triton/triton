{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-08-01";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "spl";
    rev = "576865be20ce4a0d4365cd62a589edec070fe08c";
    sha256 = "308114947465034ec96d0c6f2f77fdb296f9c17fd7773987add07fac6c1cc9b7";
  };

  patches = [ ./patches.patch ];
})
