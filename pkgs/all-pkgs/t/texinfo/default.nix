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
  name = "texinfo-6.3";

  src = fetchurl {
    url = "mirror://gnu/texinfo/${name}.tar.xz";
    sha256 = "246cf3ffa54985118ec2eea2b8d0c71b92114efe6282c2ae90d65029db4cf93a";
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
