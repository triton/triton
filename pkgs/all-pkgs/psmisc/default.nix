{ stdenv
, autoreconfHook
, fetchurl

, ncurses
}:

assert stdenv.isLinux;

stdenv.mkDerivation rec {
  name = "psmisc-${version}";
  version = "22.21";

  src = fetchurl {
    url = "https://gitlab.com/psmisc/psmisc/repository/"
        + "archive.tar.gz?ref=v${version}";
    name = "${name}.tar.gz";
    sha256 = "15k506r9p5d9clrcgis6vdh6pqk77af5a8lf233cqjc0465n5g9y";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [ncurses];

  # From upstream, will be in next release.
  patches = [ ./0001-Typo-in-fuser-makes-M-on-all-the-time.patch ];

  meta = {
    homepage = http://psmisc.sourceforge.net/;
    description = "A set of small useful utilities that use the proc filesystem (such as fuser, killall and pstree)";
    platforms = stdenv.lib.platforms.linux;
  };
}
