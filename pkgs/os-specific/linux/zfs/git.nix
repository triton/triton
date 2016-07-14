{ callPackage, stdenv, fetchFromGitHub, spl_git, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-07-13";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "ae25d222354a8074a4db0d85992fc049e2da3089";
    sha256 = "115b2df303c22ac42f318538bb4bc405942d414cebbdd589d54a9201cdb5a72f";
  };

  patches = [ ./nix-build.patch ];

  spl = spl_git;
})
