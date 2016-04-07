{ stdenv
, fetchurl
, gettext

, glib
, gobject-introspection
}:

let
  inherit (stdenv.lib)
    enFlag;
in

stdenv.mkDerivation rec {
  name = "json-glib-${version}";
  versionMajor = "1.2";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/json-glib/${versionMajor}/${name}.tar.xz";
    sha256 = "99d6dfbe49c08fd7529f1fe8dcb1893b810a1bb222f1e7b65f41507658b8a7d3";
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
    (enFlag "introspection" (gobject-introspection != null) null)
    "--enable-nls"
    "--enable-rpath"
  ];

  meta = with stdenv.lib; {
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
