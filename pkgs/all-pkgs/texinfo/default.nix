{ stdenv
, fetchurl
, perl

, interactive ? true, ncurses
}:

let
  inherit (stdenv.lib) optionals;
in
stdenv.mkDerivation rec {
  name = "texinfo-6.1";

  src = fetchurl {
    url = "mirror://gnu/texinfo/${name}.tar.xz";
    sha256 = "1ll3d0l8izygdxqz96wfr2631kxahifwdknpgsx2090vw963js5c";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = optionals interactive [
    ncurses
  ];

  preInstall = ''
    installFlagsArray+=("TEXMF=$out/texmf-dist")
  '';

  installTargets = [
    "install"
    "install-tex"
  ];

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
