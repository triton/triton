{ stdenv
, fetchurl

, libbsd
, ncurses
}:

let
  version = "2016-10-05";
  rev = stdenv.lib.replaceStrings ["-"] [""] version;
in
stdenv.mkDerivation rec {
  name = "mg-${version}";

  src = fetchurl {
    url = "https://homepage.boetes.org/software/mg/mg-${rev}.tar.gz";
    multihash = "QmZGHhLQyBojc3BifQRjtoJ4r8dMyCm6Wtv7Fr6Ny1YnZU";
    sha256 = "b7fcb5136a6783ca24c8463ab0852fc1f26bdb2bb1c24759b2c51ccfc46c5e61";
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

  meta = with stdenv.lib; {
    description = "Micro GNU/emacs, an EMACS style editor";
    homepage = http://homepage.boetes.org/software/mg/;
    license = licenses.publicDomain;
    platforms = with platforms;
      x86_64-linux;
  };
}
