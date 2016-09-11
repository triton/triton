{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-09-07";

  src = fetchFromGitHub {
    version = 2;
    owner = "zfsonlinux";
    repo = "spl";
    rev = "4fd75d35af1f101ad2ab3e98220f4e52a24532f6";
    sha256 = "29bdb4b9d75f09f1c509bf0716e14aaf3f2b2aecb08a7dc0a8947c06dd29eb21";
  };

  patches = [ ./patches.patch ];
})
