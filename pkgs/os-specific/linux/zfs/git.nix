{ callPackage, stdenv, fetchFromGitHub, spl_git, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2015-12-07";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "24ef51f660b0eb4e1507c440f4bcf0c6b38f31d0";
    sha256 = "021rgkxg8b3ibw9lh346yaxjbmpyp947gccn20img19v40b2qlh8";
  };

  patches = [ ./nix-build.patch ];

  spl = spl_git;
})
