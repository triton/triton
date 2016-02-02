{ stdenv
, fetchurl
, gettext
, intltool

, glib
, gobject-introspection
, gvfs
, json-glib
, libsoup
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "geocode-glib-${version}";
  versionMajor = "3.18";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/geocode-glib/${versionMajor}/${name}.tar.xz";
    sha256 = "0rf302vbpc6mlf8n7ns2k4n9zfgidj5kwimpj219ni3m4pw2plbm";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    glib
    gobject-introspection
    gvfs
    json-glib
    libsoup
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-rpath"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-debug"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--enable-cxx-warnings"
    "--disable-iso-cxx"
  ];

  meta = with stdenv.lib; {
    description = "GLib geocoding library uses the Yahoo! Place Finder service";
    homepage = https://git.gnome.org/browse/geocode-glib;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };

}
