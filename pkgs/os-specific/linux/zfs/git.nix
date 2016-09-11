{ callPackage, stdenv, fetchFromGitHub, spl_git, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-09-09";

  src = fetchFromGitHub {
    version = 2;
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "89f67518e1c25a586ba2663210ec9791f12f1fba";
    sha256 = "5adfbefaac41d32e2b9c2ceeef0ac443f37989a656ae3b13516a2fb72e8aa03c";
  };

  patches = [
    ./nix-build-git.patch
  ];

  spl = spl_git;
})
