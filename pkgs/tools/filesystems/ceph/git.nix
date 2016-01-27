{ callPackage, fetchgit, fetchTritonPatch, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-01-27";

  src = fetchgit {
    url = "git://github.com/ceph/ceph.git";
    rev = "7e0a7a3d44cb49b1852cfc9aaf5401582c837fd4";
    sha256 = "19qxl75afh7a81bky082x6k4h19cln5m23jf1vxc8nvmmp2n18ja";
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
