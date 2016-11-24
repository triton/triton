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
}:

let
  inherit (lib)
    boolEn
    boolWt;
in
stdenv.mkDerivation rec {
  name = "pinentry-0.9.7";

  src = fetchurl {
    url = "mirror://gnupg/pinentry/${name}.tar.bz2";
    sha256 = "6398208394972bbf897c3325780195584682a0d0c164ca5a0da35b93b1e4e7b2";
  };

  buildInputs = [
    gcr
    gtk_2
    libassuan
    libcap
    libgpg-error
    libsecret
    ncurses
    qt5
  ];

  postPatch = ''
    sed -i pinentry/pinentry-curses.c \
      -e 's/ncursesw/ncurses/'
  '';

  configureFlags = [
    ""
    "--disable-maintainer-mode"
    "--${boolEn (ncurses != null)}-pinentry-curses"
    "--enable-pinentry-tty"
    "--enable-rpath"
    "--disable-pinentry-emacs"
    "--disable-inside-emacs"
    "--${boolEn (gtk_2 != null)}-pinentry-gtk2"
    "--${boolEn (gtk_2 != null && gcr != null)}-pinentry-gnome3"
    "--${boolEn (libsecret != null)}-libsecret"
    "--${boolEn (qt5 != null)}-pinentry-qt"
    "--${boolEn (qt5 != null)}-pinentry-qt5"
    "--${boolWt (libcap != null)}-libcap"
  ];

  NIX_LDFLAGS = [
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
