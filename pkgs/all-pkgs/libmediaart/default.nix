{ stdenv
, fetchurl

, glib
, gdk-pixbuf
, gobject-introspection
, qt5
, vala
}:

with {
  inherit (stdenv.lib)
    enFlag
    optionals;
};

assert gdk-pixbuf != null -> qt5 == null;
assert qt5 != null ->
  gdk-pixbuf == null
  && qt5.qtbase != null;

stdenv.mkDerivation rec {
  name = "libmediaart-${version}";
  versionMajor = "1.9";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/libmediaart/${versionMajor}/${name}.tar.xz";
    sha256 = "0vshvm3sfwqs365glamvkmgnzjnmxd15j47xn0ak3p6l57dqlrll";
  };

  buildInputs = [
    gdk-pixbuf
    glib
    gobject-introspection
    vala
  ] ++ optionals (qt5 != null) [
    qt5.qtbase
  ];

  configureFlags = [
    "--disable-installed-tests"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "introspection" (gobject-introspection != null) null)
    (enFlag "vala" (vala != null) null)
    (enFlag "gdkpixbuf" (gdk-pixbuf != null) null)
    (enFlag "qt" (qt5 != null) null)
    "--enable-nemo"
    "--disable-unit-tests"
    "--with-compile-warnings"
  ];

  meta = with stdenv.lib; {
    description = "Manages, extracts and handles media art caches";
    homepage = https://github.com/GNOME/libmediaart;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
