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
    enFlag
    optionals
    wtFlag;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "clutter-${source.version}";

  src = fetchurl {
    url = "mirror://gnome-insecure/sources/clutter/${channel}/${name}.tar.xz";
    sha256Url = "mirror://gnome-secure/sources/clutter/${channel}/${name}.sha256sum";
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
    (enFlag "x11-backend" (xorg != null) null)
    "--disable-win32-backend"
    "--disable-quartz-backend"
    "--enable-gdk-backend"
    (enFlag "wayland-backend" (wayland != null) null)
    "--enable-egl-backend"
    "--disable-mir-backend"
    "--disable-cex100-backend"
    # TODO: tslib, touch screen support
    "--disable-tslib-input"
    "--enable-evdev-input"
    (enFlag "wayland-compositor" (wayland != null) null)
    (enFlag "xinput" (xorg != null) null)
    (enFlag "gdk-pixbuf" (gdk-pixbuf != null) null)
    "--disable-debug"
    "--disable-deprecated"
    "--disable-maintainer-flags"
    #"--disable-Werror"
    "--disable-gcov"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-docs"
    "--enable-nls"
    "--enable-rpath"
    "--disable-installed-tests"
    "--disable-always-build-tests"
    "--disable-examples"
    (wtFlag "x" (xorg != null) null)
  ];

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
