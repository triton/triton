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
, fontconfig
, gdk-pixbuf
, glib
, gobject-introspection
, json-glib
, libepoxy
, libice
, libsm
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
, opengl-dummy
, pango
, rest
, shared-mime-info
, wayland
, wayland-protocols
, xorgproto

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt
    optionals;

  broadway_backend = true;
  wayland_backend =
    opengl-dummy.egl && wayland != null && wayland-protocols != null;
  x11_backend = opengl-dummy.glx && libx11 != null;

  sources = {
    "3.22" = {
      version = "3.22.29";
      sha256 = "a07d64b939fcc034a066b7723fdf9b24e92c9cfb6a8497593f3471fe56fbbbf8";
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
    fontconfig
    gdk-pixbuf
    glib
    gobject-introspection
    json-glib
    libepoxy
    libxkbcommon
    opengl-dummy
    pango
    rest
    shared-mime-info
    wayland
    wayland-protocols
    xorgproto
  ] ++ optionals opengl-dummy.glx [
    libice
    libsm
    libx11
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxinerama
    libxrandr
    libxrender
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-largefile"
    "--disable-debug"
    "--disable-installed-tests"
    "--${boolEn (x11_backend && libxkbcommon != null)}-xkb"
    "--${boolEn (x11_backend && libxinerama != null)}-xinerama"
    "--${boolEn (x11_backend && libxrandr != null)}-xrandr"
    "--${boolEn (x11_backend && libxfixes != null)}-xfixes"
    "--${boolEn (x11_backend && libxcomposite != null)}-xcomposite"
    "--${boolEn (x11_backend && libxdamage != null)}-xdamage"
    "--${boolEn x11_backend}-x11-backend"
    "--disable-win32-backend"
    "--disable-quartz-backend"
    "--enable-broadway-backend"
    "--${boolEn wayland_backend}-wayland-backend"
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
    "--enable-introspection"
    "--enable-colord"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-man"
    "--disable-doc-cross-references"
    "--enable-Bsymbolic"
    "--${boolWt x11_backend}-x"
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
