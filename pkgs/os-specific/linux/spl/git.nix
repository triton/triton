{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-05-12";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "spl";
    rev = "39cd90ef08bb6817dd57ac08e9de5c87af2681ed";
    sha256 = "03cce697b12fb472475cd019bc41c67b99a606fefd1195f5e614b15f35d39bae";
  };

  patches = [ ./patches.patch ];
})
