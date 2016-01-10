{ callPackage, fetchurl, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "3.3.20";

  src = fetchurl {
    url = "ftp://ftp.gnutls.org/gcrypt/gnutls/v3.3/gnutls-${version}.tar.xz";
    sha256 = "1slrfccg4vk3cz3rl7ha9dcli0zwnz4sd9zri8qib3vsvrf3x42c";
  };
})
