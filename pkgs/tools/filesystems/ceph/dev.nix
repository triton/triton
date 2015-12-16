{ callPackage, fetchgit, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "10.0.1";

  src = fetchgit {
    url = "https://github.com/ceph/ceph.git";
    rev = "refs/tags/v${version}";
    sha256 = "1j0rv72ci3n8z8d3p9w6b0dj6j0b9md6b988pmn59jv4fq4450nv";
  };

  patches = [ ./fix-pythonpath.patch ];
})
