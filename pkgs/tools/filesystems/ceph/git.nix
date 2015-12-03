{ callPackage, fetchgit, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2015-12-03";

  src = fetchgit {
    url = "git://github.com/ceph/ceph.git";
    rev = "46493d4ebaf0742c0c40873fbfa5665b1c52863a";
    sha256 = "1bj1bxz1lgmqpb7b4rcwr9vjxzd9prvmgxyci9d576lv4k225w7z";
  };

  patches = [ ./fix-pythonpath.patch ];
})
