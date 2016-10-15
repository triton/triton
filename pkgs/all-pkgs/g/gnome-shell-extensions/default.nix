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
  versionMajor = "3.22";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-shell-extensions/${versionMajor}/"
      + "${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/gnome-shell-extensions/${versionMajor}/"
      + "${name}.sha256sum";
    sha256 = "e6fd8974758d3e97a8708fe0b0fb92ca00b48f67bc24590ff718f756b820c6cd";
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
