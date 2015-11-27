{ callPackage, fetchgit, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "10.0.0";

  src = fetchgit {
    url = "https://github.com/ceph/ceph.git";
    rev = "refs/tags/v${version}";
    sha256 = "13235ylj1i6m3aas6zl7ca30q6422svyjcgl9cw2v40lvrwrzvy3";
  };

  patches = [ ./fix-pythonpath.patch ];
})
