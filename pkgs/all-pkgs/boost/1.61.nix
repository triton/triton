{ stdenv, callPackage, fetchurl, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "1.61.0";

  src = fetchurl {
    url = "mirror://sourceforge/boost/boost_1_61_0.tar.bz2";
    sha256 = "a547bd06c2fd9a71ba1d169d9cf0339da7ebf4753849a8f7d6fdb8feee99b640";
  };
})
