{ callPackage, fetchgit, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2015-12-09";

  src = fetchgit {
    url = "git://github.com/ceph/ceph.git";
    rev = "b63c3fa26fbecad046dcecf50f8bf11ff46fe29d";
    sha256 = "0vfpqab0w5x8v715c753q74g3viw280walzndxrni9zr53327v3l";
  };

  patches = [ ./fix-pythonpath.patch ];
})
