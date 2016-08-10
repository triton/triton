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

let
  inherit (stdenv.lib)
    enFlag;

  versionMajor = "3.20";
  version = "${versionMajor}.1";
in
stdenv.mkDerivation rec {
  name = "geocode-glib-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/geocode-glib/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/geocode-glib/${versionMajor}/"
      + "${name}.sha256sum";
    sha256 = "669fc832cabf8cc2f0fc4194a8fa464cdb9c03ebf9aca5353d7cf935ba8637a2";
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
    platforms = with platforms;
      x86_64-linux;
  };

}
