{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2015-12-08";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "spl";
    rev = "c5a8b1e163179cadcf2c5f81b000bf7f86f41369";
    sha256 = "0cgn7cgpz6z4wc0mh7l8889lxncaxhskp35kzj5js115myl8d6l5";
  };

  patches = [ ./git.patch ];
})
