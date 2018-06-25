{ stdenv
, fetchurl
, gettext
, lib
, texinfo

, acl
, alsa-lib
, cairo
, dbus
, fontconfig
, freetype
, gconf
, giflib
, glib
, gnutls
, gpm
, gtk_3
, lcms2
, libice
, libjpeg
, libpng
, librsvg
, libsm
, libtiff
, libx11
, libxcb
, libxext
, libxft
, libxfixes
, libxinerama
, libxml2
#, libxpm
, libxrandr
, libxrender
, systemd_lib
, ncurses
, xorg
, xorgproto
, zlib
}:

stdenv.mkDerivation rec {
  name = "emacs-26.1";

  src = fetchurl {
    url = "mirror://gnu/emacs/${name}.tar.xz";
    hashOutput = false;
    sha256 = "1cf4fc240cd77c25309d15e18593789c8dbfba5c2b44d8f77c886542300fd32c";
  };

  nativeBuildInputs = [
    texinfo
  ];

  buildInputs = [
    acl
    alsa-lib
    cairo
    dbus
    fontconfig
    freetype
    gconf
    giflib
    glib
    gnutls
    gpm
    gtk_3
    lcms2
    libice
    libjpeg
    libpng
    librsvg
    libsm
    libtiff
    libx11
    libxcb
    libxext
    libxft
    libxfixes
    libxinerama
    libxml2
    #libxpm
    xorg.libXpm
    libxrandr
    libxrender
    systemd_lib
    ncurses
    xorgproto
    zlib
  ];

  configureFlags = [
    "--with-x-toolkit=gtk3"
    "--with-xft"
  ];

  postPatch = ''
    sed -i lisp/international/mule-cmds.el \
      -e 's|/usr/share/locale|${gettext}/share/locale|g'

    find . -name Makefile.in -exec sed -i 's,/bin/pwd,pwd,g' {} \;

    libc=$(cat $NIX_CC/nix-support/orig-libc)
    echo "libc: $libc"
    find . -name \*.h -exec sed -i "s,/usr/lib\(64\)\?/crt\([1in]\).o,$libc/lib/crt\2.o,g" {} \;
  '';

  postInstall = ''
    mkdir -p $out/share/emacs/site-lisp/
    cp ${./site-start.el} $out/share/emacs/site-lisp/site-start.el
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "28D3 BED8 51FD F3AB 57FE  F93C 2335 87A4 7C20 7910";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  # FIXME
  buildDirCheck = false;

  meta = with lib; {
    description = "GNU Emacs 24, the extensible, customizable text editor";
    homepage = http://www.gnu.org/software/emacs/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
