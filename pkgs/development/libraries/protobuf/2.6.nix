{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2.6.1";
  # make sure you test also -A pythonPackages.protobuf
  src = fetchFromGitHub {
    owner = "google";
    repo = "protobuf";
    rev = "v${version}";
    sha256 = "3ea7b7edd5148c93dce1023e4a39bb2a9be3c1e11222d81708dfe70aea1d0e4f";
  };
})
