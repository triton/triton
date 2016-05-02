{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "0.6.5.6";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "zfs-${version}";
    sha256 = "9fd94e66820c0a11a2e788fa6051a3f1177596b9de8467c05d757b0a99b70fde";
  };

  patches = [ ./nix-build.patch ];
})
