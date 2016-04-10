{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "0.6.5.6";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "spl";
    rev = "spl-${version}";
    sha256 = "32b505b755c78db8d278327f7231ca901617c99c2ba7a602297def93d9700c40";
  };

  patches = [ ./patches.patch ];
})
