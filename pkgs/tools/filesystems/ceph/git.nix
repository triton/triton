{ callPackage, fetchgit, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2015-01-14";

  src = fetchgit {
    url = "git://github.com/ceph/ceph.git";
    rev = "3daf908ba0e5288031e672dd78966aecffc873cf";
    sha256 = "0j9jal14vprwi88aki0xmgd7ws3s482knvk06hvizra8x2i7xc5d";
  };

  patches = [ ./fix-pythonpath.patch ];
})
