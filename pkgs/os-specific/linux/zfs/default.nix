{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "0.6.5.6";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "zfs-${version}";
    sha256 = "edf2b34ad6f44cfc78c66b265d3eba6eff0ad6285e62fc83bf2f8da6fdec2928";
  };

  patches = [ ./nix-build.patch ];
})
