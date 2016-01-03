{ stdenv
, fetchurl
, intltool
, pkgconfig
, python

, dbus_glib
, glib
, gobject-introspection
, popt
, xorg
}:

stdenv.mkDerivation rec {
  name = "at-spi2-core-${version}";
  versionMajor = "2.18";
  versionMinor = "3";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/at-spi2-core/${versionMajor}/${name}.tar.xz";
    sha256 = "0afn4x04j5l352vj0dccb2hkpzg3l2vhr8h1yv89fpqmjkfnm8md";
  };

  configureFlags = [
    "--enable-nls"
    "--enable-x11"
    "--disable-xevie"
    "--enable-introspection"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--with-x"
    "--with-dbus-daemondir=/run/current-system/sw/bin/"
  ];

  nativeBuildInputs = [
    intltool
    python
  ];

  buildInputs = [
    dbus_glib
    glib
    popt
    gobject-introspection
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXi
    xorg.libXtst
    xorg.xextproto
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "D-Bus accessibility specifications and registration daemon";
    homepage = https://wiki.gnome.org/Accessibility;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
