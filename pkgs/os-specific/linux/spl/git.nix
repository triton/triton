{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-10-07";

  src = fetchFromGitHub {
    version = 2;
    owner = "zfsonlinux";
    repo = "spl";
    rev = "0d267566650d89bde8bd5ec4665749810d5bafc7";
    sha256 = "3f5f167d978019b1dcafaea2a9af8ca19a18a4e24aa9cf9a00d69c4035e93745";
  };

  patches = [ ./patches.patch ];

  maxKernelVersion = "4.9";
})
