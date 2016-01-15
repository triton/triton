{ callPackage, fetchgit, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "10.0.2";

  src = fetchgit {
    url = "https://github.com/ceph/ceph.git";
    rev = "refs/tags/v${version}";
    sha256 = "019817ipp9k0nycwg8m0k9jgbs776sf481dqi6fx19j818jwyzdq";
  };

  patches = [ ./fix-pythonpath.patch ];
})
