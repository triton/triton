{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "0.6.5.6";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "zfs-${version}";
    sha256 = "ebf6a6d107d1c0571d0896b4dfff3d3d523df56c14d4d922f4956c933b30078c";
  };

  patches = [ ./nix-build.patch ];
})
