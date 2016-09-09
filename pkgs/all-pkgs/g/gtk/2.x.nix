{ stdenv
, fetchurl
, gettext
, intltool
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
  inherit (stdenv.lib)
    boolEn
    boolString
    boolWt
    optionalString;

    channel = "2.24";
    version = "2.24.31";
in
stdenv.mkDerivation rec {
  name = "gtk+-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gtk+/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "68c1922732c7efc08df4656a5366dcc3afdc8791513400dac276009b40954658";
  };

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

  nativeBuildInputs = [
    gettext
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

  postInstall = "rm -rf $out/share/gtk-doc";

  passthru = {
    gtkExeEnvPostBuild = ''
      rm -v $out/lib/gtk-2.0/2.10.0/immodules.cache
      $out/bin/gtk-query-immodules-2.0 \
        $out/lib/gtk-2.0/2.10.0/immodules/*.so > \
        $out/lib/gtk-2.0/2.10.0/immodules.cache
    ''; # workaround for bug of nix-mode for Emacs */ '';

    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gtk+/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
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
