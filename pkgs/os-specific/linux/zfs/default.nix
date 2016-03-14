{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "0.6.5.5";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "zfs-${version}";
    sha256 = "0np03p5zkx87a0a5rw629f9m4wp5gd01c1jkh5p7h63mmvaxfdda";
  };

  patches = [ ./nix-build.patch ];
})
