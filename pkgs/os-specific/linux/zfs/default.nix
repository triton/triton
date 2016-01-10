{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "0.6.5.4";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "zfs-${version}";
    sha256 = "10zf1kdgmdiaaa3zmz4sz5aj5ql6v24wcwixlxbwhwc51mr46k50";
  };

  patches = [ ./nix-build.patch ];
})
