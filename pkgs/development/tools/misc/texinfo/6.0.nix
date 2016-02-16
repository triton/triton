{ stdenv, fetchurl, ncurses, perl, xz, libiconv, gawk, procps }:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "texinfo-6.0";

  src = fetchurl {
    url = "mirror://gnu/texinfo/${name}.tar.xz";
    sha256 = "1r3i6jyynn6ab45fxw5bms8mflk9ry4qpj6gqyry72vfd5c47fhi";
  };

  buildInputs = [ perl xz ncurses ]
    ++ optional doCheck procps; # for tests

  preInstall = ''
    installFlagsArray+=("TEXMF=$out/texmf-dist")
  '';

  installTargets = [
    "install"
    "install-tex"
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    homepage = "http://www.gnu.org/software/texinfo/";
    description = "The GNU documentation system";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
  };
}
