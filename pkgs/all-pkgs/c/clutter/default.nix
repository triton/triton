{ stdenv
, fetchurl
, gettext
, lib

, atk
, bzip2
, cairo
, cogl
, fontconfig
, freetype
, gdk-pixbuf
, glib
, gobject-introspection
, gtk
, json-glib
, libdrm
, libgudev
, libinput
, libx11
, libxcomposite
, libxdamage
, libxext
, libxi
, libxkbcommon
, libxrandr
, opengl-dummy
, pango
, systemd_lib
, tslib
, wayland
, xorgproto

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt;

  sources = {
    "1.26" = {
      version = "1.26.2";
      sha256 = "e7233314983055e9018f94f56882e29e7fc34d8d35de030789fdcd9b2d0e2e56";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "clutter-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/clutter/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    atk
    bzip2
    cairo
    cogl
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gobject-introspection
    gtk
    json-glib
    libdrm
    libgudev
    libinput
    libx11
    libxcomposite
    libxdamage
    libxext
    libxi
    libxkbcommon
    libxrandr
    opengl-dummy
    pango
    systemd_lib
    tslib
    wayland
    xorgproto
  ];

  configureFlags = [
    "--enable-glibtest"
    "--enable-Bsymbolic"
    "--${boolEn (libx11 != null)}-x11-backend"
    "--disable-win32-backend"
    "--disable-quartz-backend"
    "--enable-gdk-backend"
    "--${boolEn (wayland != null)}-wayland-backend"
    "--${boolEn opengl-dummy.egl}-egl-backend"
    "--disable-mir-backend"
    "--disable-cex100-backend"
    "--${boolEn (tslib != null)}-tslib-input"
    "--enable-evdev-input"
    "--${boolEn (wayland != null)}-wayland-compositor"
    "--${boolEn (libxi != null)}-xinput"
    "--${boolEn (gdk-pixbuf != null)}-gdk-pixbuf"
    "--disable-debug"
    "--disable-deprecated"
    "--disable-maintainer-flags"
    #"--disable-Werror"
    "--disable-gcov"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-docs"
    "--enable-nls"
    "--enable-rpath"
    "--disable-installed-tests"
    "--disable-always-build-tests"
    "--disable-examples"
    "--${boolWt (libx11 != null)}-x"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/clutter/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Library for creating graphical user interfaces";
    homepage = http://www.clutter-project.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
