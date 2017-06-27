{ stdenv
, fetchurl
, perl

, interactive ? true, ncurses
}:

let
  inherit (stdenv.lib)
    optionals;
in

stdenv.mkDerivation rec {
  name = "texinfo-6.4";

  src = fetchurl {
    url = "mirror://gnu/texinfo/${name}.tar.xz";
    sha256 = "6ae2e61d87c6310f9af7c6f2426bd0470f251d1a6deb61fba83a3b3baff32c3a";
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
      i686-linux
      ++ x86_64-linux;
  };
}
