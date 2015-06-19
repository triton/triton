{ callPackage, fetchurl, ... } @ args:

callPackage ./generic.nix (args // rec {
  psqlSchema = "9.1";
  version = "${psqlSchema}.18";

  src = fetchurl {
    url = "mirror://postgresql/source/v${version}/postgresql-${version}.tar.bz2";
    sha256 = "1a44hmcvfaa8j169ladsibmvjakw6maaxqkzz1ab8139cqkda9i7";
  };
})
