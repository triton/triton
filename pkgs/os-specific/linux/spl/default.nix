{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "0.6.5.3";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "spl";
    rev = "spl-${version}";
    sha256 = "0lj57apwsy8cfwsvg9z62k71r3qms2p87lgcdk54g7352cwziqps";
  };

  patches = [ ./const.patch ./install_prefix.patch ];
})
