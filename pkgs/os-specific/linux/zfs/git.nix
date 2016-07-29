{ callPackage, stdenv, fetchFromGitHub, spl_git, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-07-29";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "3b86aeb2952c91aeb8ed0ebf9d5e43119fa537a0";
    sha256 = "373d574f01eced6621cb06372543b879c4a877e58d75ad91fc4b5065f7fe6c5d";
  };

  patches = [ ./nix-build-git.patch ];

  spl = spl_git;
})
