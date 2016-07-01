{ callPackage, stdenv, fetchFromGitHub, spl_git, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-06-29";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "5c27b296055301f13103ca0aa98c2ded01dcd9a0";
    sha256 = "f6602aa6ed752cb7ca819453af5995c1bf6cf4c26d8330c6dc8a9e49d58ccbd7";
  };

  patches = [ ./nix-build.patch ];

  spl = spl_git;
})
