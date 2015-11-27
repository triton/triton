{ callPackage, fetchgit, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2015-11-24";

  src = fetchgit {
    url = "git://github.com/ceph/ceph.git";
    rev = "0ab602764195633ec269f5201240f8c8839ac2e8";
    sha256 = "0pzjy5hb7by5rr8vc4603xc5x6zq00rcv9lnyyhlja3483q391vh";
  };

  patches = [ ./fix-pythonpath.patch ];
})
