{ stdenv
, gettext
, fetchurl
, pkgconfig
, perl

, glib
, gobject-introspection
}:

stdenv.mkDerivation rec {
  name = "atk-${version}";
  versionMajor = "2.18";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/atk/${versionMajor}/${name}.tar.xz";
    sha256 = "0ay9s137x49f0akx658p7kznz0rdapfrd8ym54q0hlgrggblhv6f";
  };

  configureFlags = [
    "--enable-rebuilds"
    "--enable-glibtest"
    "--enable-introspection"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
  ];

  nativeBuildInputs = [
    gettext
    perl
  ];

  buildInputs = [
    glib
    gobject-introspection
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "GTK+ & GNOME Accessibility Toolkit";
    homepage = http://library.gnome.org/devel/atk/;
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
