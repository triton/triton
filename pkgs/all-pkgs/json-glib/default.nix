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
  versionMajor = "1.0";
  versionMinor = "4";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/json-glib/${versionMajor}/${name}.tar.xz";
    sha256 = "1k85vvb2prmk8aa8hmr2rp9rnbhffjgnmr18b13g24xxnqy5kww0";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    glib
    gobject-introspection
  ];

  configureflags= [
    "--enable-glibtest"
    "--enable-Bsymbolic"
    "--disable-gcov"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-man"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--enable-nls"
  ];

  meta = with stdenv.lib; {
    description = "(de)serialization support for JSON";
    homepage = http://live.gnome.org/JsonGlib;
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
