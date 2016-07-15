{ stdenv
, perl
}:

{ name
, buildInputs ? []
, preConfigure ? ""
, postFixup ? ""
, ...
} @ attrs:

stdenv.mkDerivation ({
  checkTarget = "test";
  
  # Prevent CPAN downloads.
  PERL_AUTOINSTALL = "--skipdeps";

  # Avoid creating perllocal.pod, which contains a timestamp
  installTargets = "pure_install";

  # From http://wiki.cpantesters.org/wiki/CPANAuthorNotes: "allows
  # authors to skip certain tests (or include certain tests) when
  # the results are not being monitored by a human being."
  AUTOMATED_TESTING = true;
} // attrs // {
  name = "perl-" + name;

  buildInputs = [
    perl
  ] ++ buildInputs;

  preConfigure = preConfigure + ''
    export PERL5LIB="$PERL5LIB${PERL5LIB:+:}$out/lib/perl5/site_perl"

    perlFlags=()
    for i in $(IFS=:; echo $PERL5LIB); do
      perlFlags+=("-I$i")
    done

    find . | while read fn; do
      if test -f "$fn"; then
        first=$(dd if="$fn" count=2 bs=1 2> /dev/null)
        if test "$first" = "#!"; then
          echo "patching $fn..."
          sed -i "s|^#\!\(.*/perl.*\)$|#\! \1$perlFlags|" "$fn"
        fi
      fi
    done

    perl Makefile.PL "PREFIX=$out" "INSTALLDIRS=site" $makeMakerFlags
  '';

  postFixup = ''
    # If a user installs a Perl package, she probably also wants its
    # dependencies in the user environment (since Perl modules don't
    # have something like an RPATH, so the only way to find the
    # dependencies is to have them in the PERL5LIB variable).
    if test -e $out/nix-support/propagated-native-build-inputs; then
      ln -s $out/nix-support/propagated-native-build-inputs $out/nix-support/propagated-user-env-packages
    fi
  '' + postFixup;
})
