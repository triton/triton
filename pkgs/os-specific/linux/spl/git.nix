{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-09-21";

  src = fetchFromGitHub {
    version = 2;
    owner = "zfsonlinux";
    repo = "spl";
    rev = "8acfb2bcc118555fed2c0902c33d300a57630368";
    sha256 = "4019bffdba6cc7bd55d9cc6977b85fdd6a1eb942528c0cf0d000d138fabc5b77";
  };

  patches = [ ./patches.patch ];
})
