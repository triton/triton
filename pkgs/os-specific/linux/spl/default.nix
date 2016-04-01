{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "0.6.5.6";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "spl";
    rev = "spl-${version}";
    sha256 = "556a8f25da45bc42bb7f4c57a910ef9427f79fe2a923d3b10278d4d1e4f09e31";
  };

  patches = [ ./patches.patch ];
})
