{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2015-01-08";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "spl";
    rev = "466bcf3be5040e161219a7aab14b618a672d4402";
    sha256 = "0l8pfbi0k5mw7wcsk7840hn1h0d2pmal9iaxnq9jxpakxr7asmsk";
  };

  patches = [ ./patches.patch ];
})
