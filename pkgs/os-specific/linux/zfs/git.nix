{ callPackage, stdenv, fetchFromGitHub, spl_git, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-08-16";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "8658115c19f84b30d68402c32a33a2157c97e4f1";
    sha256 = "df1e0fa4ba7b1f21b2ee9750acb240f173e3faa48a98c649f28dba614c473795";
  };

  patches = [
    ./nix-build-git.patch
  ];

  spl = spl_git;
})
