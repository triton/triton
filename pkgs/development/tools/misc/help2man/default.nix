{ stdenv, fetchurl, perl, gettext, perlPackages, makeWrapper }:

stdenv.mkDerivation rec {
  name = "help2man-1.47.3";

  src = fetchurl {
    url = "mirror://gnu/help2man/${name}.tar.xz";
    sha256 = "0miqq77ssk5rgsc9xlv7k5n2wk2c5wv2m1kh4zhbwrggfmjaycn2";
  };

  nativeBuildInputs = [ makeWrapper perl gettext ];

  postInstall = ''
    wrapProgram "$out/bin/help2man" \
      --prefix PERL5LIB : "$(echo ${perlPackages.LocaleGettext}/lib/perl*/site_perl)"
  '';


  meta = with stdenv.lib; {
    description = "Generate man pages from `--help' output";
    homepage = http://www.gnu.org/software/help2man/;
    license = licenses.gpl3Plus;
    platforms = platforms.all;
  };
}
