{ stdenv
, fetchurl
, gettext
, perl

, at-spi2-atk
, atk
, cairo
, colord
, cups
, epoxy
, expat
, fontconfig
, gdk-pixbuf
, glib
, gobject-introspection
, gnome-wrapper
, json-glib
, libxkbcommon
, mesa_noglu
, pango
, rest
, shared_mime_info
, wayland
, wayland-protocols
, xorg
}:

with {
  inherit (stdenv.lib)
    enFlag
    optionals
    wtFlag;
};

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
in

stdenv.mkDerivation rec {
  name = "gtk+-${version}";
  versionMajor = "3.20";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gtk+/${versionMajor}/${name}.tar.xz";
    sha256 = "1c3d3a4a6e959ec8636ccb074bcdb8fa25c81ec56fbc70de6a3f5ef83ba6d803";
  };

  nativeBuildInputs = [
    gettext
    perl
  ];

  buildInputs = [
    atk
    at-spi2-atk
    cairo
    colord
    cups
    epoxy
    expat
    fontconfig
    gdk-pixbuf
    glib
    gobject-introspection
    json-glib
    libxkbcommon
    mesa_noglu
    pango
    rest
    shared_mime_info
    wayland
    wayland-protocols
  ] ++ optionals (xorg != null) [
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
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-largefile"
    "--disable-debug"
    "--disable-installed-tests"
    (enFlag "xkb" (libxkbcommon != null) null)
    (enFlag "xinerama" (xorg != null) null)
    (enFlag "xrandr" (xorg != null) null)
    (enFlag "xfixes" (xorg != null) null)
    (enFlag "xcomposite" (xorg != null) null)
    (enFlag "xdamage" (xorg != null) null)
    (enFlag "x11-backend" (xorg != null) null)
    "--disable-win32-backend"
    "--disable-quartz-backend"
    (enFlag "broadway-backend" true null)
    (enFlag "wayland-backend" (
      wayland != null
      && wayland-protocols != null) null)
    "--disable-mir-backend"
    "--disable-quartz-relocation"
    #"--enable-explicit-deps"
    "--enable-glibtest"
    #"--enable-modules"
    (enFlag "cups" (cups != null) null)
    "--disable-papi"
    (enFlag "cloudprint" (rest != null && json-glib != null) null)
    (enFlag "test-print-backend" (cups != null) null)
    "--enable-schemas-compile"
    (enFlag "introspection" (gobject-introspection != null) null)
    (enFlag "colord" (colord != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-man"
    "--disable-doc-cross-references"
    "--enable-Bsymbolic"
    (wtFlag "x" (xorg != null) null)
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  # TODO: disable unnecessary tests
  doCheck = false;

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
