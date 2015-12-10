{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "0.6.5.3";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "zfs-${version}";
    sha256 = "1hq65kq50hzhd1zqgyzqq2whg1fckigq8jmhhdsnbwrwmx5y76lh";
  };

  patches = [ ./nix-build.patch ];
})
