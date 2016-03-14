{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "0.6.5.5";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "spl";
    rev = "spl-${version}";
    sha256 = "1f49qv648klg2sn1v1wzwd6ls1njjj0hrazz7msd74ayhwm0zcw7";
  };

  patches = [ ./patches.patch ];
})
