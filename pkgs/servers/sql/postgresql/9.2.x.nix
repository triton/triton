{ callPackage, fetchurl, ... } @ args:

callPackage ./generic.nix (args // rec {
  psqlSchema = "9.2";
  version = "${psqlSchema}.13";

  src = fetchurl {
    url = "mirror://postgresql/source/v${version}/postgresql-${version}.tar.bz2";
    sha256 = "0i3avdr8mnvn6ldkx0hc4jmclhisb2338hzs0j2m03wck8hddjsx";
  };
})
