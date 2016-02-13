{ stdenv
, fetchurl
, gettext
, intltool

, atk
, gconf
, gdk-pixbuf
, geocode-glib
, glib
, gobjectIntrospection
, gtk3
, libsoup
, libxml2
, pango
, tzdata
}:

stdenv.mkDerivation rec {
  name = "libgweather-${version}";
  versionMajor = "3.18";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/libgweather/${versionMajor}/${name}.tar.xz";
    sha256 = "1l3sra84k5dnavbdbjyf1ar84xmjszpnnldih6mf45kniwpjkcll";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    atk
    gconf
    gdk-pixbuf
    geocode-glib
    glib
    gobjectIntrospection
    gtk3
    libsoup
    libxml2
    pango
  ];

  configureFlags = [
    "--enable-schemas-compile"
    "--enable-compile-warnings"
    "--enable-glibtest"
    "--enable-nls"
    "--enable-rpath"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-introspection"
    "--disable-vala"
    "--with-zoneinfo-dir=${tzdata}/share/zoneinfo"
  ];

  meta = with stdenv.lib; {
    description = "Library to access weather information from online services";
    homepage = https://wiki.gnome.org/Projects/LibGWeather;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
