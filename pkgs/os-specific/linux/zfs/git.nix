{ callPackage, stdenv, fetchFromGitHub, spl_git, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-09-25";

  src = fetchFromGitHub {
    version = 2;
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "680eada9b05415a8e564eb345f062f357d66f0f1";
    sha256 = "6c8065ba00bbc326c3a36608f67c8eb9b9fdfa12f6b62ba2045293d0f58280f4";
  };

  patches = [
    ./nix-build-git.patch
  ];

  spl = spl_git;

  maxKernelVersion = "4.9";
})
