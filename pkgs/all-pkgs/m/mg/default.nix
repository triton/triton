{ stdenv
, fetchFromGitHub
, lib

, libbsd
, ncurses
}:

let
  version = "2018-04-08";
  rev = stdenv.lib.replaceStrings ["-"] [""] version;
in
stdenv.mkDerivation rec {
  name = "mg-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "hboetes";
    repo = "mg";
    inherit rev;
    sha256 = "f744fba2ca7a569984d36bf76684b777248003ec11a6a08eabc8453786301b94";
  };

  buildInputs = [
    libbsd
    ncurses
  ];

  postPatch = ''
    sed -i 's|/usr/bin/||' GNUmakefile
  '';

  makefile = "GNUmakefile";

  makeFlags = [
    "prefix=$(out)"
  ];

  meta = with lib; {
    description = "Micro GNU/emacs, an EMACS style editor";
    homepage = http://homepage.boetes.org/software/mg/;
    license = licenses.publicDomain;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
