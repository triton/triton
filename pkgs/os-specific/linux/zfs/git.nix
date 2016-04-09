{ callPackage, stdenv, fetchFromGitHub, spl_git, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-04-05";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "2b54cb14517b8b3877716dbe02fe75f12a47eb5e";
    sha256 = "6738c6f22996566a19e5bebc30f460225d75e8a75bf2e776c0c692ed6daeef9b";
  };

  patches = [ ./nix-build.patch ];

  spl = spl_git;
})
