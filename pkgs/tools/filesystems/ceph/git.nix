{ callPackage, fetchgit, fetchTritonPatch, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-02-08";

  src = fetchgit {
    url = "git://github.com/ceph/ceph.git";
    rev = "f22b671434f0f3640244d05d2f72fcc0eb3696f3";
    sha256 = "0hky9yjx1ry2ss64mflsjdjl3fabwpz8x59gfqzw31b64g5p4704";
  };

  patches = [
    (fetchTritonPatch {
      rev = "a8e11633b115050e9d0ea558d6480ed1d5fe9eeb";
      file = "ceph/fix-pythonpath.patch";
      sha256 = "0iq52pa4i0nldm5mmm8bshbpzbmrjndswa1cysglcmv2ncbvmyzz";
    })
    (fetchTritonPatch {
      rev = "3e20a6c39775b724eff44af93f08b38205be1f5b";
      file = "ceph/0001-Makefile-env-Don-t-force-sbin.patch";
      sha256 = "025agxpjkp5dj1fpx2ln0j9s43wklzgld6v6zk3vmgs0l4q138g0";
    })
  ];
})
