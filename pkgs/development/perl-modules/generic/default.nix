{ perl }:

{ buildInputs ? [], ... } @ attrs:

perl.stdenv.mkDerivation (
  {
    doCheck = false;
    
    checkTarget = "test";
    
    # Prevent CPAN downloads.
    PERL_AUTOINSTALL = "--skipdeps";

    # Avoid creating perllocal.pod, which contains a timestamp
    installTargets = "pure_install";

    # From http://wiki.cpantesters.org/wiki/CPANAuthorNotes: "allows
    # authors to skip certain tests (or include certain tests) when
    # the results are not being monitored by a human being."
    AUTOMATED_TESTING = true;
  }
  //
  attrs
  //
  {
    name = "perl-" + attrs.name;
    builder = ./builder.sh;
    buildInputs = buildInputs ++ [ perl ];
  }
)
