{ callPackage, stdenv, fetchFromGitHub, spl_git, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-08-01";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "e24e62a948e1519fb4c1bfc40d9d51e36fbbe63e";
    sha256 = "bd1c488cc12f6254be571c114f619328f5ce4a37137fd8be740dca09b6dd79cb";
  };

  patches = [ ./nix-build-git.patch ];

  spl = spl_git;
})
