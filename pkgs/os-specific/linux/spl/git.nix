{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-03-17";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "spl";
    rev = "224817e2a81912b46453a96b9eec4804856c801b";
    sha256 = "e2a1ea61b783cf692bedb6d9b08bd1e8765df3c95861d4d9c69c89181a3e132a";
  };

  patches = [ ./patches.patch ];
})
