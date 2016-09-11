{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "0.6.5.8";

  src = fetchFromGitHub {
    version = 2;
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "zfs-${version}";
    sha256 = "2eb73910e4728bc280f982361e0c0139f944d52e2a55c06e2b8f0ebe6e452e82";
  };

  patches = [ ./nix-build.patch ];
})
