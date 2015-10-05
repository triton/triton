{ callPackage, fetchgit, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2015-10-03";

  src = fetchgit {
    url = "git://github.com/ceph/ceph.git";
    rev = "d1e697628931775e7fcdbb79a76ddd8e7dedffd5";
    sha256 = "0ziyc6v25vcb3j0b8044hdxn6rbpmbnhwid4ch9xg4h1f747d1m6";
  };

  patches = [ ./fix-pythonpath.patch ];
})
