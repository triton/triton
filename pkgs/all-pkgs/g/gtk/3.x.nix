{ stdenv
, fetchurl
, gettext
, makeWrapper
, perl

, at-spi2-atk
, atk
, cairo
, colord
, cups
, expat
, fontconfig
, gdk-pixbuf
, glib
, gobject-introspection
, gnome-wrapper
, json-glib
, libepoxy
, libxkbcommon
, mesa_noglu
, pango
, rest
, shared_mime_info
, wayland
, wayland-protocols
, xorg

, channel
}:

assert xorg != null ->
  xorg.inputproto != null
  && xorg.libICE != null
  && xorg.libSM != null
  && xorg.libX11 != null
  && xorg.libXcomposite != null
  && xorg.libXcursor != null
  && xorg.libXdamage != null
  && xorg.libXext != null
  && xorg.libXfixes != null
  && xorg.libXi != null
  && xorg.libXinerama != null
  && xorg.libXrandr != null
  && xorg.libXrender != null;

let
  inherit (stdenv.lib)
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
    if xorg != null then
      true
    else
      false;

  source = (import ./3-sources.nix { })."${channel}";
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
    fontconfig
    gdk-pixbuf
    glib
    gobject-introspection
    json-glib
    libepoxy
    libxkbcommon
    mesa_noglu
    pango
    rest
    shared_mime_info
    wayland
    wayland-protocols
  ] ++ optionals (xorg != null) [
    xorg.fixesproto
    xorg.inputproto
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXrender
    xorg.xproto
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-largefile"
    "--disable-debug"
    "--disable-installed-tests"
    "--${boolEn (libxkbcommon != null)}-xkb"
    "--${boolEn (xorg != null)}-xinerama"
    "--${boolEn (xorg != null)}-xrandr"
    "--${boolEn (xorg != null)}-xfixes"
    "--${boolEn (xorg != null)}-xcomposite"
    "--${boolEn (xorg != null)}-xdamage"
    "--${boolEn (xorg != null)}-x11-backend"
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
    "--${boolWt (xorg != null)}-x"
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  preFixup = ''
    wrapProgram $out/bin/gtk3-demo-application \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH"

    wrapProgram $out/bin/gtk3-widget-factory \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH"
  '';

  # FIXME
  buildDirCheck = false;

  passthru = {
    inherit
      broadway_backend
      wayland_backend
      x11_backend;
    gtkExeEnvPostBuild = ''
      rm -v $out/lib/gtk-3.0/3.0.0/immodules.cache
      $out/bin/gtk-query-immodules-3.0 $out/lib/gtk-3.0/3.0.0/immodules/*.so > \
        $out/lib/gtk-3.0/3.0.0/immodules.cache
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
