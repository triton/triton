{ stdenv
, fetchurl
, cmake
, gettext
, perl

, atk
, cairo
, gdk-pixbuf
, glib
, gobject-introspection
, gtk3
, hicolor_icon_theme
, libgee
, pango
, vala
}:

stdenv.mkDerivation rec {
  name = "granite-${version}";
  versionMajor = "0.3";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "https://code.launchpad.net/granite/${versionMajor}/${version}/" +
           "+download/${name}.tar.xz";
    sha256 = "1inyq9qhayzg1kl7nc6i275k9yqdicl23rs5lyrz2xdsk8gxdhcf";
  };

  nativeBuildInputs = [
    cmake
    gettext
    perl
  ];

  buildInputs = [
    atk
    cairo
    gdk-pixbuf
    glib
    libgee
    gobject-introspection
    gtk3
    hicolor_icon_theme
    pango
    vala
  ];

  cmakeFlags = [
    "-DINTROSPECTION_GIRDIR=\${out}/share/gir-1.0/"
    "-DINTROSPECTION_TYPELIBDIR=\${out}/lib/girepository-1.0"
  ];

  meta = with stdenv.lib; {
    description = "An extension to GTK+ used by elementary OS";
    homepage = https://launchpad.net/granite;
    license = licenses.lgpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
