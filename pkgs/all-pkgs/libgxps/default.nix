{ stdenv
, fetchurl

, cairo
, glib
, freetype
, gobject-introspection
, lcms2
, libarchive
, libjpeg
, libpng
, libtiff
}:

with {
  inherit (stdenv.lib)
    enFlag
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "libgxps-${version}";
  versionMajor = "0.2";
  versionMinor = "3.2";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/libgxps/${versionMajor}/${name}.tar.xz";
    sha256 = "09s19ci9j5zvy7bmasii7m7sxrdjy6skh7p309klwnk6hpnz19bf";
  };

  buildInputs = [
    cairo
    glib
    freetype
    gobject-introspection
    lcms2
    libarchive
    libjpeg
    libpng
    libtiff
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--enable-cxx-warnings"
    "--disable-iso-cxx"
    "--disable-debug"
    "--disable-test"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-man"
    (enFlag "introspection" (gobject-introspection != null) null)
    (wtFlag "libjpeg" (libjpeg != null) null)
    (wtFlag "libtiff" (libtiff != null) null)
    (wtFlag "liblcms2" (lcms2 != null) null)
  ];

  meta = with stdenv.lib; {
    description = "Library for handling and rendering XPS documents";
    homepage = https://wiki.gnome.org/Projects/libgxps;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
