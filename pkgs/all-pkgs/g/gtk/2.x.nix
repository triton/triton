{ stdenv
, autoreconfHook
, fetchFromGitHub
, gettext
, gtk-doc
, intltool
, lib
, perl

, atk
, cairo
, cups
, fontconfig
, gdk-pixbuf_unwrapped
, gdk-pixbuf
, glib
, gobject-introspection
, libxkbcommon
, pango
, xorg
}:

let
  inherit (lib)
    boolEn
    boolString
    boolWt
    optionalString;

    channel = "2.24";
    version = "${channel}-2017-03-27";
in
stdenv.mkDerivation rec {
  name = "gtk+-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "GNOME";
    repo = "gtk";
    rev = "4435fb3c612da10522bf4f709b66887a055e4cab";
    sha256 = "0e24db8d1d157e8fec7283cb7ef90a91c7e8c2879b600c9a317831b8f977f53e";
  };

  nativeBuildInputs = [
    autoreconfHook  # Just used to include all dependencies
    gettext
    gtk-doc  # autoreconf
    intltool
    perl
  ];

  buildInputs = [
    atk
    cairo
    cups
    fontconfig
    gdk-pixbuf_unwrapped
    gdk-pixbuf
    glib
    gobject-introspection
    libxkbcommon
    pango
    xorg.inputproto
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXext
    xorg.libXfixes
    xorg.libXdamage
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXrender
  ];

  autoreconfPhase = ''
    gtkdocize --copy

    touch README  # File is expected to exist

    # autoreconfHook doesn't use $ACLOCAL_FLAGS so it must be run manually
    aclocal --force -I m4/
    libtoolize --copy --force
    autoheader
    automake --force-missing --add-missing
    autoconf --force
  '';

  configureFlags = [
    "--${boolEn (xorg.libXext != null)}-shm"
    "--${boolEn (libxkbcommon != null)}-xkb"
    "--${boolEn (xorg.libXinerama != null)}-xinerama"
    "--enable-rebuilds"
    "--enable-visibility"
    "--enable-explicit-deps"
    "--enable-glibtest"
    "--enable-modules"
    "--disable-quartz-relocation"
    "--${boolEn (cups != null)}-cups"
    "--disable-papi"
    "--${boolEn (cups != null)}-test-print-backend"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-man"
    "--${boolWt (xorg.libXi != null)}-xinput"
    "--${boolWt (xorg != null)}-gdktarget${
      boolString (xorg != null) "=x11" ""}"
    #"--with-gdktarget=directfb"
    "--${boolWt (xorg != null)}-x"
  ];

  postInstall = "rm -rf $out/share/gtk-doc";

  passthru = {
    gtkExeEnvPostBuild = ''
      rm -v $out/lib/gtk-2.0/2.10.0/immodules.cache
      $out/bin/gtk-query-immodules-2.0 \
        $out/lib/gtk-2.0/2.10.0/immodules/*.so > \
        $out/lib/gtk-2.0/2.10.0/immodules.cache
    ''; # workaround for bug of nix-mode for Emacs */ '';

    # srcVerification = fetchurl {
    #   inherit (src)
    #     outputHash
    #     outputHashAlgo
    #     urls;
    #   sha256Url = "https://download.gnome.org/sources/gtk+/${channel}/"
    #     + "${name}.sha256sum";
    #   failEarly = true;
    # };
  };

  meta = with lib; {
    description = "A toolkit for creating graphical user interfaces";
    homepage = http://www.gtk.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
