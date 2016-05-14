{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "0.6.5.7";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "zfs-${version}";
    sha256 = "83d5212deb91b29e149b5983faf55ec9714739aca49c38a05980c215b9aa0caf";
  };

  patches = [ ./nix-build.patch ];
})
