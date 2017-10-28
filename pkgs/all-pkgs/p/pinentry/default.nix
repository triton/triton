{ stdenv
, fetchurl
, gnupg
, lib
, makeWrapper

, gcr
, gnome-themes-standard
, gtk_2
, libassuan
, libcap
, libgpg-error
, libsecret
, ncurses
, shared-mime-info
, qt5

, type
}:

let
  inherit (lib)
    any
    boolEn
    boolWt
    optionals
    optionalString;

  isNox = type == "nox";
  isGtk = type == "gtk";
  isQt = type == "qt";
in
assert isNox || isGtk || isQt;
stdenv.mkDerivation rec {
  name = "pinentry-1.0.0";

  src = fetchurl {
    url = "mirror://gnupg/pinentry/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "1672c2edc1feb036075b187c0773787b2afd0544f55025c645a71b4c2f79275a";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    libassuan
    libcap
    libgpg-error
  ] ++ optionals isNox [
    ncurses
  ] ++ optionals isGtk [
    gcr
    gnome-themes-standard
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

  preFixup = optionalString isGtk ''
    wrapProgram $out/bin/pinentry-gtk-2 \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share" \
      --run "$DEFAULT_GTK2_RC_FILES"
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") urls;
      inherit (gnupg.srcVerification) pgpKeyFingerprints;
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

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
