{ stdenv
, fetchurl
, gettext

, atk
, bzip2
, cairo
, cogl
, fontconfig
, freetype
, gdk-pixbuf
, glib
, gobject-introspection
, gtk3
, json-glib
, libdrm
, libgudev
, libinput
, libxkbcommon
, mesa
, pango
, systemd_lib
, xorg
, wayland

, channel
}:

assert xorg != null ->
  xorg.inputproto != null
  && xorg.libX11 != null
  && xorg.libXcomposite != null
  && xorg.libXdamage != null
  && xorg.libXext != null
  && xorg.libXi != null
  && xorg.libXrandr != null;

let
  inherit (stdenv.lib)
    boolEn
    boolWt
    optionals;

  source = (import ./sources.nix { })."${channel}";
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
    gtk3
    json-glib
    libdrm
    libgudev
    libinput
    libxkbcommon
    mesa
    pango
    systemd_lib
    wayland
  ] ++ optionals (xorg != null) [
    xorg.inputproto
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXi
    xorg.libXrandr
  ];

  configureFlags = [
    "--enable-glibtest"
    "--enable-Bsymbolic"
    "--${boolEn (xorg != null)}-x11-backend"
    "--disable-win32-backend"
    "--disable-quartz-backend"
    "--enable-gdk-backend"
    "--${boolEn (wayland != null)}-wayland-backend"
    "--enable-egl-backend"
    "--disable-mir-backend"
    "--disable-cex100-backend"
    # TODO: tslib, touch screen support
    "--disable-tslib-input"
    "--enable-evdev-input"
    "--${boolEn (wayland != null)}-wayland-compositor"
    "--${boolEn (xorg != null)}-xinput"
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
    "--${boolWt (xorg != null)}-x"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/clutter/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
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
