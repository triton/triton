{ callPackage, stdenv, fetchFromGitHub, spl_git, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-05-12";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "a9bb2b682785d48b4bcdaca9d382fc87bbf6e2fb";
    sha256 = "e0c8bee918f48841a960ffa1456a1f1ec04d6e1ba802abb271cf7c47c9e0861e";
  };

  patches = [ ./nix-build.patch ];

  spl = spl_git;
})
