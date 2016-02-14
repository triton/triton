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
, udev
, xorg
, wayland
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "clutter-${version}";
  versionMajor = "1.24";
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/clutter/${versionMajor}/${name}.tar.xz";
    sha256 = "0qyd0cw17wi8gl6y9z2j2lh2gwghxskfmsdvw4ayrgxwnj6cjccn";
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
    udev
    wayland
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
    "--enable-x11-backend"
    "--disable-win32-backend"
    "--disable-quartz-backend"
    "--enable-wayland-backend"
    "--enable-egl-backend"
    "--disable-mir-backend"
    "--disable-cex100-backend"
    "--enable-wayland-compositor"
    "--enable-tslib-input"
    "--enable-evdev-input"
    "--enable-xinput"
    "--enable-gdk-pixbuf"
    "--disable-debug"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-deprecated"
    "--disable-maintainer-flags"
    "--disable-gcov"
    "--enable-introspection"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-docs"
    "--enable-nls"
    "--enable-rpath"
    "--disable-installed-tests"
    "--disable-always-build-tests"
    "--disable-examples"
    "--with-x"
  ];

  meta = with stdenv.lib; {
    description = "Library for creating graphical user interfaces";
    license = licenses.lgpl2Plus;
    homepage = http://www.clutter-project.org/;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
