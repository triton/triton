{ callPackage, stdenv, fetchFromGitHub, spl_git, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-08-19";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "2bce8049c3d782f4feb72493564754c0595606bf";
    sha256 = "0a6e273442201e30fbd7a02077e2932cb9ed4cdca3cba199cb5fef5dba18adb9";
  };

  patches = [
    ./nix-build-git.patch
  ];

  spl = spl_git;
})
