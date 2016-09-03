{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-08-19";

  src = fetchFromGitHub {
    version = 1;
    owner = "zfsonlinux";
    repo = "spl";
    rev = "aeb9baa618beea1458ab3ab22cbc0f39213da6cf";
    sha256 = "5c5a26ee76aec1f4f3f1cbc570825da35c97e4d5fcb06cdb5989a0a7ff50d4ba";
  };

  patches = [ ./patches.patch ];
})
