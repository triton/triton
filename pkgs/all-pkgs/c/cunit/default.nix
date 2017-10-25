{ stdenv
, autoreconfHook
, fetchurl

, ncurses
}:

let
  version = "2.1-3";
in
stdenv.mkDerivation rec {
  name = "CUnit-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/cunit/CUnit/${version}/${name}.tar.bz2";
    sha256 = "f5b29137f845bb08b77ec60584fdb728b4e58f1023e6f249a464efa49a40f214";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    ncurses
  ];

  configureFlags = [
    "--enable-curses"
  ];

  disableStatic = false;

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
