{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "0.6.5.8";

  src = fetchFromGitHub {
    version = 2;
    owner = "zfsonlinux";
    repo = "spl";
    rev = "spl-${version}";
    sha256 = "3c83c08bdaf6741572ae2135edc527119449b7bba8792dd5ccdfe9992f85c9ba";
  };

  patches = [ ./patches.patch ];
})
