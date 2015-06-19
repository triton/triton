{ callPackage, fetchurl, ... } @ args:

callPackage ./generic.nix (args // rec {
  psqlSchema = "9.4";
  version = "${psqlSchema}.4";

  src = fetchurl {
    url = "mirror://postgresql/source/v${version}/postgresql-${version}.tar.bz2";
    sha256 = "04q07g209y99xzjh88y52qpvz225rxwifv8nzp3bxzfni2bdk3jk";
  };
})
