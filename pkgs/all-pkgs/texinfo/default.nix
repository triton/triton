{ stdenv
, fetchurl
, perl

, interactive ? true, ncurses
, check ? true, procps
}:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "texinfo-6.0";

  src = fetchurl {
    url = "mirror://gnu/texinfo/${name}.tar.xz";
    sha256 = "1r3i6jyynn6ab45fxw5bms8mflk9ry4qpj6gqyry72vfd5c47fhi";
  };

  nativeBuildInputs = [ perl ];
  buildInputs = [ ]
    ++ optional interactive ncurses
    ++ optional doCheck procps; # for tests

  preInstall = ''
    installFlagsArray+=("TEXMF=$out/texmf-dist")
  '';

  installTargets = [
    "install"
    "install-tex"
  ];

  doCheck = check;

  meta = with stdenv.lib; {
    homepage = "http://www.gnu.org/software/texinfo/";
    description = "The GNU documentation system";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux
      ++ i686-linux
    ;
  };
}
