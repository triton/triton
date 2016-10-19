{ callPackage, stdenv, fetchFromGitHub, spl_git, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-10-19";

  src = fetchFromGitHub {
    version = 2;
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "9d70aec6fde90112b5b5610ab5c17b6883b97063";
    sha256 = "41e2ca622c4f11cbc60836b3ec83b2e7a38855891e7ff70688c41de3aaeda35e";
  };

  patches = [
    ./nix-build-git.patch
  ];

  spl = spl_git;

  maxKernelVersion = "4.9";
})
