{ stdenv
, fetchurl
, gettext
, perl

, adwaita-icon-theme
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
, librsvg
, libxkbcommon
, mesa_noglu
, pango
, rest
, shared_mime_info
, wayland
, xlibsWrapper
, xorg
}:

with {
  inherit (stdenv.lib)
    enFlag
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "gtk+-${version}";
  versionMajor = "3.18";
  versionMinor = "7";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gtk+/${versionMajor}/${name}.tar.xz";
    sha256 = "0848wr702kvpayrlvggn3wys5im564kqyxzn6hkmrkj5mjq1qvm7";
  };

  # demos fail to install, no idea where the problem is
  postPatch = "sed '/^SRC_SUBDIRS /s/demos//' -i Makefile.in";

  configureFlags = [
    (enFlag "xkb" (libxkbcommon != null) null)
    (enFlag "xinerama" (xorg.libXinerama != null) null)
    (enFlag "xrandr" (xorg.libXrandr != null) null)
    (enFlag "xfixes" (xorg.libXfixes != null) null)
    (enFlag "xcomposite" (xorg.libXcomposite != null) null)
    (enFlag "xdamage" (xorg.libXdamage != null) null)
    (enFlag "x11-backend" (true) null) # xorg deps
    "--disable-win32-backend"
    "--disable-quartz-backend"
    (enFlag "broadway-backend" true null)
    (enFlag "wayland-backend" (wayland != null) null)
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

  nativeBuildInputs = [
    gettext
    perl
  ];

  propagatedBuildInputs = [
    gnome-wrapper
  ];

  buildInputs = [
    adwaita-icon-theme
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
    librsvg
    libxkbcommon
    mesa_noglu
    pango
    rest
    shared_mime_info
    wayland
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

  postInstall = "rm -rvf $out/share/gtk-doc";

  # TODO: disable unnecessary tests
  doCheck = false;
  enableParallelBuilding = true;

  passthru = {
    gtkExeEnvPostBuild = ''
      rm $out/lib/gtk-3.0/3.0.0/immodules.cache
      $out/bin/gtk-query-immodules-3.0 $out/lib/gtk-3.0/3.0.0/immodules/*.so > \
        $out/lib/gtk-3.0/3.0.0/immodules.cache
    ''; # workaround for bug of nix-mode for Emacs */ '';
  };

  meta = with stdenv.lib; {
    description = "A toolkit for creating graphical user interfaces";
    homepage = http://www.gtk.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
