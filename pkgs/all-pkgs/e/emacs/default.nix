{ stdenv
, fetchurl
, gettext
, lib
, texinfo

, acl
, alsa-lib
, dbus
, fontconfig
, freetype
, gconf
, giflib
, glib
, gnutls
, gpm
, gtk_3
, libice
, libjpeg
, libpng
, librsvg
, libsm
, libtiff
, libx11
, libxcb
, libxft
, libxfixes
, libxinerama
, libxml2
#, libxpm
, libxrandr
, libxrender
, ncurses
, xorg
, zlib
}:

stdenv.mkDerivation rec {
  name = "emacs-25.3";

  src = fetchurl {
    url = "mirror://gnu/emacs/${name}.tar.xz";
    hashOutput = false;
    sha256 = "253ac5e7075e594549b83fd9ec116a9dc37294d415e2f21f8ee109829307c00b";
  };

  nativeBuildInputs = [
    texinfo
  ];

  buildInputs = [
    acl
    alsa-lib
    dbus
    fontconfig
    freetype
    gconf
    giflib
    glib
    gnutls
    gpm
    gtk_3
    libice
    libjpeg
    libpng
    librsvg
    libsm
    libtiff
    libx11
    libxcb
    libxft
    libxfixes
    libxinerama
    libxml2
    #libxpm
    xorg.libXpm
    libxrandr
    libxrender
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

  doCheck = true;

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
