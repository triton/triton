{ callPackage, stdenv, fetchFromGitHub, spl_git, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-07-19";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "1d9b3bd8fb2b633b7523d9f39149d76e24ffb535";
    sha256 = "08069e01ef193222211a0685ecd73de05817bf8fc1ec2b25ed4bef53b40af4e6";
  };

  patches = [ ./nix-build.patch ];

  spl = spl_git;
})
