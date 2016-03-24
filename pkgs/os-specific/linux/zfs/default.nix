{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "0.6.5.6";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "zfs-${version}";
    sha256 = "0lsb93y5zbwc8fafxzm9vyfpr6fmvl8h86ny4llbd2xy2hnfwk2i";
  };

  patches = [ ./nix-build.patch ];
})
