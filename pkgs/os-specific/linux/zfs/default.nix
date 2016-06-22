{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "0.6.5.7";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "zfs-${version}";
    sha256 = "dea2d70ac4d838f7f71b9a37681286aadd53d07f2511d334bd6a0a8234292e6f";
  };

  patches = [ ./nix-build.patch ];
})
