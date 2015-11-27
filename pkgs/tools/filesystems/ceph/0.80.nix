{ callPackage, fetchgit, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "0.80.11";

  src = fetchgit {
    url = "git://github.com/ceph/ceph.git";
    rev = "refs/tags/v${version}";
    sha256 = "1qa6bxbyzm7gn2xg28qmrai3ws4chkhcfcavrkbc128mf8i52kb8";
  };

  patches = [
    ./0001-Cleanup-boost-optionals.patch
    ./fix-pgrefdebugging.patch
    ./boost-158.patch
  ];
})
