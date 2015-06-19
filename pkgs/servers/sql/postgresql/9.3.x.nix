{ callPackage, fetchurl, ... } @ args:

callPackage ./generic.nix (args // rec {
  psqlSchema = "9.3";
  version = "${psqlSchema}.9";

  src = fetchurl {
    url = "mirror://postgresql/source/v${version}/postgresql-${version}.tar.bz2";
    sha256 = "0j85j69rf54cwz5yhrhk4ca22b82990j5sqb8cr1fl9843nd0fzp";
  };
})
