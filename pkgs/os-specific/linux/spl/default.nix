{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "0.6.5.7";

  src = fetchFromGitHub {
    version = 1;
    owner = "zfsonlinux";
    repo = "spl";
    rev = "spl-${version}";
    sha256 = "2c9ab022c217c2c99aea6953180bcbbee356aa83a77933531523b36d685162a4";
  };

  patches = [ ./patches.patch ];
})
