{ stdenv
, autoreconfHook
, fetchFromGitHub
, fetchTritonPatch
, flex
, gettext
}:

stdenv.mkDerivation rec {
  name = "recode-2014-02-02";

  src = fetchFromGitHub {
    version = 6;
    owner = "pinard";
    repo = "Recode";
    rev = "2d7092a9999194fc0e9449717a8048c8d8e26c18";
    sha256 = "ab747d1259b7081b8bd19497ecd0292cf5a4e116bbc22ff8d457c74668a0aecd";
  };

  nativeBuildInputs = [
    autoreconfHook
    flex
    gettext
  ];

  patches = [
    /* Revert site overhaul patch which hardcodes a search path */
    (fetchTritonPatch {
      rev = "c9e7ebdfba032d6333c68c71199d7f6e5151d995";
      file = "recode/recode-3.7-pre-remove-site.patch";
      sha256 = "814e4ac5719b4c417c423562655228f386f137782b3688b46e2afbd4995ae82c";
    })
  ];

  postPatch =
    /* fix build with new automake */ ''
      rm -v Makefile.in
      sed -i {,src/}Makefile.am \
        -e 's,ACLOCAL = ./aclocal.sh @ACLOCAL@,,' \
        -e 's/ansi2knr//'
      sed -i configure.ac \
        -e '/^AM_C_PROTOTYPES/d'
    '';

  configureFlags = [
    "--enable-rpath"
    "--enable-nls"
    "--without-dmalloc"
  ];

  meta = with stdenv.lib; {
    description = "Converts files between various character sets and usages";
    homepage = http://www.gnu.org/software/recode/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
