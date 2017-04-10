{ stdenv
, fetchurl
, lib

, libbsd
, ncurses
}:

let
  version = "2017-04-01";
  rev = stdenv.lib.replaceStrings ["-"] [""] version;
in
stdenv.mkDerivation rec {
  name = "mg-${version}";

  src = fetchurl {
    url = "https://homepage.boetes.org/software/mg/mg-${rev}.tar.gz";
    multihash = "QmNbDUe1yzSsKhxt11xFZDh97hfevWvG9111V5iAXYkdnj";
    sha256 = "0a3608b17c153960cb1d954ca3b62445a77c0c1a18aa5c8c58aba9f6b8d62aab";
  };

  buildInputs = [
    libbsd
    ncurses
  ];

  postPatch =
    /* Remove OpenBSD specific easter egg */ ''
      sed -i GNUmakefile \
        -e 's/theo\.o//'
      sed -i main.c \
        -e '/theo_init/d'
    '' + /* Remove hardcoded paths */ ''
      sed -i GNUmakefile \
        -e 's|/usr/bin/||'
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
