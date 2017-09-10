{ stdenv
, fetchurl
, gettext
, lib
, makeWrapper
, perl

, at-spi2-atk
, atk
, cairo
, colord
, cups
, expat
, fixesproto
, fontconfig
, gdk-pixbuf
, glib
, gobject-introspection
, inputproto
, json-glib
, libepoxy
, libice
, libsm
, libx11
, libxcomposite
, libxdamage
, libxext
, libxfixes
, libxinerama
, libxkbcommon
, libxrandr
, libxrender
, mesa_noglu
, pango
, rest
, shared-mime-info
, wayland
, wayland-protocols
, xorg
, xproto

, channel
}:

assert libx11 != null ->
  xorg.libXcursor != null
  && xorg.libXi != null;

let
  inherit (lib)
    boolEn
    boolWt
    optionals;

  broadway_backend = true;
  wayland_backend =
    if wayland != null && wayland-protocols != null then
      true
    else
      false;
  x11_backend =
    if libx11 != null then
      true
    else
      false;

  sources = {
    "3.22" = {
      version = "3.22.20";
      sha256 = "70c90998a7809f60dc0a7439a68c34e59077dadb631657a6f9cab6a5539c02d9";
    };
    "3.91" = {
      version = "3.91.1";
      sha256 = "a6c1fb8f229c626a3d9c0e1ce6ea138de7f64a5a6bc799d45fa286fe461c3434";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "gtk+-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gtk+/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    makeWrapper
    perl
  ];

  buildInputs = [
    atk
    at-spi2-atk
    cairo
    colord
    cups
    expat
    fixesproto
    fontconfig
    gdk-pixbuf
    glib
    gobject-introspection
    inputproto
    json-glib
    libepoxy
    libice
    libsm
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxinerama
    libxkbcommon
    libxrandr
    libxrender
    mesa_noglu
    pango
    rest
    shared-mime-info
    wayland
    wayland-protocols
    xproto
  ] ++ optionals (libx11 != null) [
    xorg.libXcursor
    xorg.libXi
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-largefile"
    "--disable-debug"
    "--disable-installed-tests"
    "--${boolEn (libxkbcommon != null)}-xkb"
    "--${boolEn (libxinerama != null)}-xinerama"
    "--${boolEn (libxrandr != null)}-xrandr"
    "--${boolEn (libxfixes != null)}-xfixes"
    "--${boolEn (libxcomposite != null)}-xcomposite"
    "--${boolEn (libxdamage != null)}-xdamage"
    "--${boolEn (libx11 != null)}-x11-backend"
    "--disable-win32-backend"
    "--disable-quartz-backend"
    "--${boolEn true}-broadway-backend"
    "--${boolEn (
      wayland != null
      && wayland-protocols != null)}-wayland-backend"
    "--disable-mir-backend"
    "--disable-quartz-relocation"
    #"--enable-explicit-deps"
    "--enable-glibtest"
    #"--enable-modules"
    "--${boolEn (cups != null)}-cups"
    "--disable-papi"
    "--${boolEn (rest != null && json-glib != null)}-cloudprint"
    "--${boolEn (cups != null)}-test-print-backend"
    "--enable-schemas-compile"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--${boolEn (colord != null)}-colord"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-man"
    "--disable-doc-cross-references"
    "--enable-Bsymbolic"
    "--${boolWt (libx11 != null)}-x"
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  preFixup = ''
    wrapProgram $out/bin/gtk3-demo-application \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH"

    wrapProgram $out/bin/gtk3-widget-factory \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH"
  '';

  buildDirCheck = false;  # FIXME

  passthru = {
    inherit
      broadway_backend
      wayland_backend
      x11_backend;

    # workaround for bug of nix-mode for Emacs
    gtkExeEnvPostBuild = ''
      rm -v $out/lib/gtk-3.0/3.0.0/immodules.cache
      $out/bin/gtk-query-immodules-3.0 $out/lib/gtk-3.0/3.0.0/immodules/*.so > \
        $out/lib/gtk-3.0/3.0.0/immodules.cache
    '';

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
