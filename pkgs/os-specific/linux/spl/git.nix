{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-03-17";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "spl";
    rev = "224817e2a81912b46453a96b9eec4804856c801b";
    sha256 = "a020ef1e38c54c8e2093d1bb549c948a044980f83aa5f4466722567bb92fc0e6";
  };

  patches = [ ./patches.patch ];
})
