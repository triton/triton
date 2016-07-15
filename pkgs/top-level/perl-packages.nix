{ stdenv
, pkgs
, perl
, self
}:

let
  callPackage = pkgs.newScope (self // {
    inherit pkgs;
    perlPackages = self;
  });
in {

inherit perl;

buildPerlPackage = callPackage ../all-pkgs/build-perl-package { };

################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
############################### BEGIN ALL PKGS #################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################

DBD-SQLite = callPackage ../all-pkgs/DBD-SQLite { };

DBI = callPackage ../all-pkgs/DBI { };

Encode-Locale = callPackage ../all-pkgs/Encode-Locale { };

HTTP-Date = callPackage ../all-pkgs/HTTP-Date { };

HTTP-Message = callPackage ../all-pkgs/HTTP-Message { };

Locale-gettext = callPackage ../all-pkgs/Locale-gettext { };

SGMLS = callPackage ../all-pkgs/SGMLS { };

URI = callPackage ../all-pkgs/URI { };

WWW-Curl = callPackage ../all-pkgs/WWW-Curl { };

XML-Parser = callPackage ../all-pkgs/XML-Parser { };
}
