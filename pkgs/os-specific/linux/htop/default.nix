{ stdenv
, fetchurl
, ncurses
}:

stdenv.mkDerivation rec {
  name = "htop-${version}";
  version = "2.0.0";

  src = fetchurl {
    url = "http://hisham.hm/htop/releases/${version}/${name}.tar.gz";
    sha256 = "1d944hn0ldxvxfrz9acr26lpmzlwj91m0s7x2xnivnfnmfha4p6i";
  };

  buildInputs = [
    ncurses
  ];

  postPatch = ''
    touch *.h */*.h # unnecessary regeneration requires Python
  '';

  meta = {
    description = "An interactive process viewer for Linux";
    homepage = "http://htop.sourceforge.net";
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ rob simons relrod ];
  };
}
