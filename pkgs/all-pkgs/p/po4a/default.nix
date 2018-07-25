{ stdenv
, docbook_xml_dtd_412
, docbook-xsl
, fetchurl
, gettext
, glibcLocales
, libxslt
, makeWrapper
, perlPackages
}:

let
  version = "0.54";
in
stdenv.mkDerivation rec {
  name = "po4a-${version}";

  src = fetchurl {
    url = "https://github.com/mquinson/po4a/releases/download/v${version}/${name}.tar.gz";
    sha256 = "596f7621697f9dd12709958c229e256b56683d25997ac73c9625a2cc0c603d51";
  };

  # Perl needs en_US.UTF-8
  LOCALE_ARCHIVE = "${glibcLocales}/lib/locale/locale-archive";

  nativeBuildInputs = [
    docbook_xml_dtd_412
    docbook-xsl
    gettext
    libxslt
    makeWrapper
    perlPackages.LocaleGettext
    perlPackages.ModuleBuild
    perlPackages.perl
    perlPackages.SGMLSpm
    perlPackages.TermReadKey
    perlPackages.TextWrapI18N
    perlPackages.UnicodeLineBreak
  ];

  configurePhase = ''
    perl Build.PL installdirs=vendor create_packlist=0
  '';

  buildPhase = ''
    LC_ALL=en_US.UTF-8 perl Build
  '';

  installPhase = ''
    find . -name \*.pm
    perl Build destdir=$out install
    dir="$out/${perlPackages.perl}"
    mv "$dir"/* "$out"
    while [ "$dir" != "$out" ]; do
      rmdir "$dir"
      dir="$(dirname "$dir")"
    done

    mkdir -p "$out/${perlPackages.perl.libPrefix}"
    cp -r blib/lib/* "$out/${perlPackages.perl.libPrefix}"
  '';

  preFixup = ''
    progs=($(find $out/bin -type f))
    for prog in "''${progs[@]}"; do
      wrapProgram "$prog" \
        --prefix PATH : "$out/bin:${gettext}/bin" \
        --prefix PERL5LIB : "$out/${perlPackages.perl.libPrefix}"
    done
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
