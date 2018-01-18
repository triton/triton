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
, gdk-pixbuf
, glib
, gobject-introspection
, inputproto
, libx11
, libxcomposite
, libxcursor
, libxdamage
, libxext
, libxfixes
, libxi
, libxinerama
, libxkbcommon
, libxrandr
, libxrender
, pango
, shared-mime-info
}:

let
  inherit (lib)
    boolEn
    boolString
    boolWt
    optionalString;

    channel = "2.24";
    version = "${channel}-2017-08-07";
in
stdenv.mkDerivation rec {
  name = "gtk+-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "GNOME";
    repo = "gtk";
    rev = "bf8c1c212ebc6d05b534aa1c0edff73103e9cc56";
    sha256 = "72be94622c5318bdc6c787515fd805ac4028f71aa5b4fac33abb1e52197c2c62";
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
    gdk-pixbuf
    glib
    gobject-introspection
    inputproto
    libx11
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxinerama
    libxkbcommon
    libxrandr
    libxrender
    pango
    shared-mime-info
  ];

  postPatch = /* Our gdk-pixbuf does not include loaders.cache so one must be provided. */ ''
    sed -i gtk/Makefile.am \
      -e 's,$(gtk_update_icon_cache_program),GDK_PIXBUF_MODULE_FILE="${gdk-pixbuf.loaders.cache}" $(gtk_update_icon_cache_program),'
  '' + /* Don't waste time building demos and examples */ ''
    rm -rfv {demos,examples}/
    sed -i configure.ac \
      -i Makefile.am \
      -e '/demos\//d' \
      -e 's/\sdemos\s/ /' \
      -e '/examples\//d'
  '';

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
    "--${boolEn (libxext != null)}-shm"
    "--${boolEn (libxkbcommon != null)}-xkb"
    "--${boolEn (libxinerama != null)}-xinerama"
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
    "--${boolWt (libxi != null)}-xinput"
    "--${boolWt (libx11 != null)}-gdktarget${
      boolString (libx11 != null) "=x11" ""}"
    #"--with-gdktarget=directfb"
    "--${boolWt (libx11 != null)}-x"
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
