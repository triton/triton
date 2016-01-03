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
}:

stdenv.mkDerivation rec {
  name = "librsvg-${version}";
  versionMajor = "2.40";
  versionMinor = "12";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url    = "mirror://gnome/sources/librsvg/${versionMajor}/${name}.tar.xz";
    sha256 = "0l5mzwlw6k20hvndvk5xllks20xbddr7b93rsvs9jf5zg11hrr7z";
  };

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-pixbuf-loader"
    "--enable-Bsymbolic"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-tools"
    "--enable-introspection"
    "--disable-vala"
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
  ];

  enableParallelBuilding = true;
}
