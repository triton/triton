{ stdenv
, autoreconfHook
, fetchTritonPatch
, fetchurl

, ncurses
}:

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

  buildInputs = [
    ncurses
  ];

  patches = [
    # From upstream, will be in next release.
    (fetchTritonPatch {
      rev = "0f7d71c8d72ed94cd06270096d82c1275fe42fb7";
      file = "psmisc/0001-Typo-in-fuser-makes-M-on-all-the-time.patch";
      sha256 = "e1e88176f1620f932e5f38027a5f9a5b03c163aa5ce12b26e6440ea471840a3f";
    })
  ];

  meta = with stdenv.lib; {
    description = "A set of tools that use the proc filesystem";
    homepage = http://psmisc.sourceforge.net/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
