{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "0.6.5.6";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "spl";
    rev = "spl-${version}";
    sha256 = "f5da9a53d6b382ca1918a4459d1a8555def79c5a58194d2381ceffdabf7e08e5";
  };

  patches = [ ./patches.patch ];
})
