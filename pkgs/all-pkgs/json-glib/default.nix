{ stdenv
, fetchurl
, gettext

, glib
, gobject-introspection
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "json-glib-${version}";
  versionMajor = "1.1";
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/json-glib/${versionMajor}/${name}.tar.xz";
    sha256 = "e00f84018306e1aa234285d77b6c2b5d57c1e1d4dabc4dfc62d30b9670941bda";
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
