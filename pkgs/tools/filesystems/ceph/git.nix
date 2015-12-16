{ callPackage, fetchgit, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2015-12-15";

  src = fetchgit {
    url = "git://github.com/ceph/ceph.git";
    rev = "1d7b53f42f32c23e24662a094bba8d63c1419e06";
    sha256 = "16yx6yncczy22gap2qlqzankncxa5lq29bqmyq3fhjng5fg1jldp";
  };

  patches = [ ./fix-pythonpath.patch ];
})
