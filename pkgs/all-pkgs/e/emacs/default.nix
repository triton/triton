{ stdenv
, fetchurl
, gettext
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
, gtk3
, libjpeg
, libpng
, librsvg
, libtiff
, libxml2
, ncurses
, xorg
, zlib
}:

stdenv.mkDerivation rec {
  name = "emacs-25.2";

  src = fetchurl {
    url = "mirror://gnu/emacs/${name}.tar.xz";
    hashOutput = false;
    sha256 = "59b55194c9979987c5e9f1a1a4ab5406714e80ffcfd415cc6b9222413bc073fa";
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
    gtk3
    libjpeg
    libpng
    librsvg
    libtiff
    libxml2
    ncurses
    xorg.kbproto
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXft
    xorg.libXfixes
    xorg.libXinerama
    xorg.libXpm
    xorg.libXrandr
    xorg.libXrender
    xorg.libxcb
    xorg.xproto
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

  meta = with stdenv.lib; {
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
