{ stdenv
, fetchurl
, gettext
, intltool

, atk
, gconf
, gdk-pixbuf
, geocode-glib
, glib
, gobject-introspection
, gtk3
, libsoup
, libxml2
, pango
, tzdata
, vala
}:

let
  inherit (stdenv.lib)
    enFlag
    wtFlag;
in

stdenv.mkDerivation rec {
  name = "libgweather-${version}";
  versionMajor = "3.20";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/libgweather/${versionMajor}/${name}.tar.xz";
    sha256 = "52629b8e9fcd979377f43a2223cf0e7096d3c3e940faa94021132ee0f879b8d6";
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
    gobject-introspection
    gtk3
    libsoup
    libxml2
    pango
    vala
  ];

  configureFlags = [
    "--enable-schemas-compile"
    "--enable-compile-warnings"
    #"--disable-Werror"
    "--enable-glibtest"
    "--enable-nls"
    "--disable-glade-catalog"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "introspection" (gobject-introspection != null) null)
    (enFlag "vala" (vala != null) null)
    (wtFlag "zoneinfo-dir" (tzdata != null) "${tzdata}/share/zoneinfo")
  ];

  meta = with stdenv.lib; {
    description = "Library to access weather information from online services";
    homepage = https://wiki.gnome.org/Projects/LibGWeather;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
