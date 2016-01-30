{ stdenv
, fetchurl
, gettext
, intltool

, adwaita-icon-theme
, cairo
, enchant
, glib
, gsettings-desktop-schemas
, gtk3
, isocodes
, libsoup
, pango
}:

stdenv.mkDerivation rec {
  name = "gtkhtml-${version}";
  versionMajor = "4.10";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gtkhtml/${versionMajor}/${name}.tar.xz";
    sha256 = "ca3b6424fb2c7ac5d9cb8fdafb69318fa2e825c9cf6ed17d1e38d9b29e5606c3";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    adwaita-icon-theme
    cairo
    enchant
    glib
    gsettings-desktop-schemas
    gtk3
    isocodes
    libsoup
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-shlib-factory"
    "--without-glade-catalog"
  ];

  meta = with stdenv.lib; {
    description = "Lightweight HTML rendering/printing/editing engine";
    homepage = https://git.gnome.org/browse/gtkhtml;
    license = with licenses; [
      gpl2Plus
      lgpl2Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
