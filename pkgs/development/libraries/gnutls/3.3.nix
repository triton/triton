{ callPackage, fetchurl, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "3.3.19";

  src = fetchurl {
    url = "ftp://ftp.gnutls.org/gcrypt/gnutls/v3.3/gnutls-${version}.tar.xz";
    sha256 = "1ks43xmxas9qn2dhvgqalbgc6pkfah5svnfl6fdra8cgniwqg3c8";
  };
})
