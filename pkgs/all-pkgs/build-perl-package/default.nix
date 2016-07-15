{ stdenv
, perl
}:

{ name
, buildInputs ? []
, postPatch ? ""
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

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    perl
  ] ++ buildInputs;

  postPatch = postPatch + ''
    export PERL5LIB="$PERL5LIB''${PERL5LIB:+:}$out/${perl.libPrefix}"

    perlFlags=""
    for i in $(IFS=:; echo $PERL5LIB); do
      perlFlags+=" -I$i"
    done

    while read file; do
      first=$(dd if="$file" count=2 bs=1 2> /dev/null)
      if test "$first" = "#!"; then
        echo "patching $file..."
        sed -i "s|^#\!\(.*/perl.*\)$|#\! \1$perlFlags|" "$file"
      fi
    done < <(find . -type f)
  '';

  configurePhase = ''
    runHook preConfigure
    perl Makefile.PL "PREFIX=$out" "INSTALLDIRS=site" $configureFlags "''${configureFlagsArray[@]}"
    runHook postConfigure
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
