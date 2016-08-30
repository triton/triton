{ callPackage, stdenv, fetchFromGitHub, spl_git, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-08-29";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "c40db193a5e503fffacf6d96a7dd48a0f1b36601";
    sha256 = "091b91e47a1b92fface4bd609a6afe2fb1bf727280a57776c5f6d26e123d8165";
  };

  patches = [
    ./nix-build-git.patch
  ];

  spl = spl_git;
})
