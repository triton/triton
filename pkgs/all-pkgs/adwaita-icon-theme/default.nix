{ stdenv
, fetchurl
, gettext
, intltool

, gdk-pixbuf
, hicolor_icon_theme
}:

stdenv.mkDerivation rec {
  name = "adwaita-icon-theme-${version}";
  versionMajor = "3.18";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/adwaita-icon-theme/${versionMajor}/${name}.tar.xz";
    sha256 = "5e9ce726001fdd8ee93c394fdc3cdb9e1603bbed5b7c62df453ccf521ec50e58";
  };

  configureFlags = [
    # nls creates unused directories
    "--disable-nls"
    "--enable-w32-cursors"
    "--disable-l-xl-variants"
  ];

  nativeBuildInputs = [
    gettext
    intltool
  ];

  propagatedBuildInputs = [
    # For convenience, we can specify adwaita-icon-theme only in packages
    hicolor_icon_theme
  ];

  buildInputs = [
    gdk-pixbuf
  ];

  doCheck = false;

  meta = with stdenv.lib; {
    description = "GNOME default icon theme";
    homepage = https://git.gnome.org/browse/adwaita-icon-theme/;
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
