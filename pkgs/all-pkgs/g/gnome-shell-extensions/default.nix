{ stdenv
, fetchurl
, gettext
, intltool
, itstool

, adwaita-icon-theme
, atk
, clutter
, file
, gdk-pixbuf
, glib
, gnome-menus
, gnome-shell
, gobject-introspection
, gtk3
, libgtop
, pango
, telepathy_glib
}:

stdenv.mkDerivation rec {
  name = "gnome-shell-extensions-${version}";
  versionMajor = "3.20";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-shell-extensions/${versionMajor}/"
      + "${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/gnome-shell-extensions/${versionMajor}/"
      + "${name}.sha256sum";
    sha256 = "e84a075d895ca3baeefb8508e0a901027b66f7d5a7ee8c966e31d301b38e78e7";
  };

  nativeBuildInputs = [
    gettext
    intltool
    itstool
  ];

  buildInputs = [
    adwaita-icon-theme
    atk
    clutter
    file
    gdk-pixbuf
    glib
    gnome-menus
    gnome-shell
    gobject-introspection
    gtk3
    libgtop
    pango
    telepathy_glib
  ];

  configureFlags = [
    "--enable-nls"
    "--enable-schemas-compile"
    "--enable-extensions=all"
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "JavaScript extensions for GNOME Shell";
    homepage = https://wiki.gnome.org/Projects/GnomeShell/Extensions;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
