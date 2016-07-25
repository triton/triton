{ callPackage, stdenv, fetchFromGitHub, spl_git, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-07-21";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "f4bc1bbe11042de49226c69f0334c77af30024b4";
    sha256 = "32ffd8b12f0fccb4cd8751108b1c6a7524c7a1d6d536dc5652f689c0599b003a";
  };

  patches = [ ./nix-build-git.patch ];

  spl = spl_git;
})
