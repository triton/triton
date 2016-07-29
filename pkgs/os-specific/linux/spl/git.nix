{ callPackage, fetchFromGitHub, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "2016-07-29";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "spl";
    rev = "b7c7008ba28ca926fbda929aec52f3761d72cffe";
    sha256 = "0760492b71c928d070b997271605c3999e3defef3a845b4e2eb91f06183c05c4";
  };

  patches = [ ./patches.patch ];
})
