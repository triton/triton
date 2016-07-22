{ stdenv
, fetchurl

, libassuan
, libcap
, libgpg-error
, libsecret
, ncurses
, qt5
}:

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
    libsecret
    ncurses
    qt5
  ];

  prePatch = ''
    substituteInPlace pinentry/pinentry-curses.c --replace ncursesw ncurses
  '';

  configureFlags = [
    "--with-libcap"
    "--enable-pinentry-curses"
    "--enable-pinentry-tty"
    "--disable-pinentry-gtk2"
    "--disable-pinentry-gnome3"
    "--enable-pinentry-qt"
  ];

  meta = with stdenv.lib; {
    homepage = "http://gnupg.org/aegypten2/";
    description = "GnuPG's interface to passphrase input";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
