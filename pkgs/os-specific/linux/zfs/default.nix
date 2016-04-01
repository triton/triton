{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "0.6.5.6";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "zfs-${version}";
    sha256 = "06eb3cfc37dc51090fd5f82913bbb5ed8affef778aa525609eab31da934117bf";
  };

  patches = [ ./nix-build.patch ];
})
