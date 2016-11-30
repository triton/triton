{ stdenv
, fetchurl
, lib

, gcr
, gtk_2
, libassuan
, libcap
, libgpg-error
, libsecret
, ncurses
, qt5

, type
}:

let
  inherit (lib)
    any
    boolEn
    boolWt
    optionals;

  isNox = type == "nox";
  isGtk = type == "gtk";
  isQt = type == "qt";
in
assert isNox || isGtk || isQt;
stdenv.mkDerivation rec {
  name = "pinentry-0.9.7";

  src = fetchurl {
    url = "mirror://gnupg/pinentry/${name}.tar.bz2";
    sha256 = "6398208394972bbf897c3325780195584682a0d0c164ca5a0da35b93b1e4e7b2";
  };

  buildInputs = [
    libassuan
    libcap
    libgpg-error
  ] ++ optionals isNox [
    ncurses
  ] ++ optionals isGtk [
    gcr
    gtk_2
    libsecret
  ] ++ optionals isQt [
    qt5
  ];

  postPatch = ''
    sed -i pinentry/pinentry-curses.c \
      -e 's/ncursesw/ncurses/'
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--${boolEn isNox}-pinentry-curses"
    "--enable-pinentry-tty"
    "--enable-rpath"
    "--disable-pinentry-emacs"
    "--disable-inside-emacs"
    "--${boolEn isGtk}-pinentry-gtk2"
    "--${boolEn isGtk}-pinentry-gnome3"
    "--${boolEn isGtk}-libsecret"
    "--${boolEn isQt}-pinentry-qt"
    "--${boolEn isQt}-pinentry-qt5"
    "--with-libcap"
  ];

  NIX_LDFLAGS = optionals isGtk [
    "-L${gcr}/lib"
  ];

  meta = with lib; {
    description = "GnuPG's interface to passphrase input";
    homepage = "http://gnupg.org/aegypten2/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
