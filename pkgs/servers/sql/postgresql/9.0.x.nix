{ callPackage, fetchurl, ... } @ args:

callPackage ./generic.nix (args // rec {
  psqlSchema = "9.0";
  version = "${psqlSchema}.22";

  src = fetchurl {
    url = "mirror://postgresql/source/v${version}/postgresql-${version}.tar.bz2";
    sha256 = "19gq6axjhvlr5zlrzwnll1fbrvai4xh0nb1jki6gmmschl6v5m4l";
  };
})
