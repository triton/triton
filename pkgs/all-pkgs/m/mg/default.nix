{ stdenv
, fetchurl
, lib

, libbsd
, ncurses
}:

let
  version = "2017-10-14";
  rev = stdenv.lib.replaceStrings ["-"] [""] version;
in
stdenv.mkDerivation rec {
  name = "mg-${version}";

  src = fetchurl {
    url = "https://homepage.boetes.org/software/mg/mg-${rev}.tar.gz";
    multihash = "QmerodBsZzGcFNn5n3Fr37cooSKoMh4fYHfXVMnjgQz3Jx";
    sha256 = "51519698f3f44acd984d7805e4e315ded50c15aba8222521f88756fd67745341";
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
