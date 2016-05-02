{ callPackage, stdenv, fetchFromGitHub, spl_git, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-04-05";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "2b54cb14517b8b3877716dbe02fe75f12a47eb5e";
    sha256 = "7e16de15c4b3ac2e48fe4218e5f2e775b7b19ce1b546274d0df3f6690a609f94";
  };

  patches = [ ./nix-build.patch ];

  spl = spl_git;
})
