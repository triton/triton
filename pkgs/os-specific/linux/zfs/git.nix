{ callPackage, stdenv, fetchFromGitHub, spl_git, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-05-12";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "a9bb2b682785d48b4bcdaca9d382fc87bbf6e2fb";
    sha256 = "3d7ba640a01a7749b8c324a9104851f061ebb0896e4c26c535ae6620c32ce224";
  };

  patches = [ ./nix-build.patch ];

  spl = spl_git;
})
