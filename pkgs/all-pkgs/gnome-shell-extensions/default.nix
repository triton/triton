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
  versionMajor = "3.18";
  versionMinor = "4";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-shell-extensions/${versionMajor}/" +
          "${name}.tar.xz";
    sha256 = "0fmpk6an2gzhys3c6gpg61ng7qlrvh3knzj4dnji9ndajkw71r4a";
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
      i686-linux
      ++ x86_64-linux;
  };
}
