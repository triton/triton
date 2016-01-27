{ callPackage, fetchgit, fetchTritonPatch, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "10.0.2";

  src = fetchgit {
    url = "https://github.com/ceph/ceph.git";
    rev = "refs/tags/v${version}";
    sha256 = "019817ipp9k0nycwg8m0k9jgbs776sf481dqi6fx19j818jwyzdq";
  };

  patches = [
    (fetchTritonPatch {
      rev = "3e20a6c39775b724eff44af93f08b38205be1f5b";
      file = "ceph/fix-pythonpath.patch";
      sha256 = "1chf2n7rac07kvvbrs00vq2nkv31v3l6lqdlqpq09wgcbin2qpkk";
    })
    (fetchTritonPatch {
      rev = "3e20a6c39775b724eff44af93f08b38205be1f5b";
      file = "ceph/0001-Makefile-env-Don-t-force-sbin.patch";
      sha256 = "025agxpjkp5dj1fpx2ln0j9s43wklzgld6v6zk3vmgs0l4q138g0";
    })
  ];
})
