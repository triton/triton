{ stdenv
, fetchurl

, bzip2
, cairo
, gdk-pixbuf-core
, glib
, gobject-introspection
, libcroco
, libgsf
, libxml2
, pango
, vala
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "librsvg-${version}";
  versionMajor = "2.40";
  versionMinor = "13";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url    = "mirror://gnome/sources/librsvg/${versionMajor}/${name}.tar.xz";
    sha256 = "014q7gz6mgfa7pfn0lr13qqv568ad8j1sw9d4vksnpazq0zajvjd";
  };

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-pixbuf-loader"
    "--enable-Bsymbolic"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-tools"
    (enFlag "introspection" (gobject-introspection != null) null)
    (enFlag "vala" (vala != null) null)
  ];

  # It wants to add loaders and update the loaders.cache in gdk-pixbuf
  # Patching the Makefiles so it creates rsvg specific loaders and the
  # relevant loader.cache here.
  postConfigure = ''
    GDK_PIXBUF=$out/lib/gdk-pixbuf-2.0/2.10.0
    mkdir -p $GDK_PIXBUF/loaders
    sed -e "s#gdk_pixbuf_moduledir = .*#gdk_pixbuf_moduledir = $GDK_PIXBUF/loaders#" \
        -i gdk-pixbuf-loader/Makefile
    sed -e "s#gdk_pixbuf_cache_file = .*#gdk_pixbuf_cache_file = $GDK_PIXBUF/loaders.cache#" \
        -i gdk-pixbuf-loader/Makefile
    sed -e "s#\$(GDK_PIXBUF_QUERYLOADERS)#GDK_PIXBUF_MODULEDIR=$GDK_PIXBUF/loaders \$(GDK_PIXBUF_QUERYLOADERS)#" \
         -i gdk-pixbuf-loader/Makefile
  '';

  buildInputs = [
    bzip2
    cairo
    gdk-pixbuf-core
    glib
    gobject-introspection
    libcroco
    libgsf
    libxml2
    pango
    vala
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Scalable Vector Graphics (SVG) rendering library";
    homepage = https://wiki.gnome.org/Projects/LibRsvg;
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
