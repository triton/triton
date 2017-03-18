{ stdenv
, fetchurl
, gettext
, lib

, glib
, gobject-introspection
}:

let
  inherit (lib)
    boolEn;

  versionMajor = "1.2";
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";
in
stdenv.mkDerivation rec {
  name = "json-glib-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/json-glib/${versionMajor}/${name}.tar.xz";
    sha256 = "ea128ab52a824fcd06e5448fbb2bd8d9a13740d51c66d445828edba71321a621";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    glib
    gobject-introspection
  ];

  configureflags= [
    "--enable-Bsymbolic"
    "--disable-debug"
    "--disable-maintainer-mode"
    "--disable-installed-tests"
    "--disable-always-build-tests"
    "--disable-gcov"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-man"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--enable-nls"
    "--enable-rpath"
  ];

  meta = with lib; {
    description = "(de)serialization support for JSON";
    homepage = http://live.gnome.org/JsonGlib;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
