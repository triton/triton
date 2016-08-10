{ stdenv
, fetchurl

, bzip2
, cairo
, gdk-pixbuf_unwrapped
, glib
, gobject-introspection
, libcroco
, libgsf
, libxml2
, pango
, vala
}:

let
  inherit (stdenv.lib)
    enFlag;
in

stdenv.mkDerivation rec {
  name = "librsvg-${version}";
  versionMajor = "2.40";
  versionMinor = "16";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/librsvg/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/librsvg/${versionMajor}/${name}.sha256sum";
    sha256 = "d48bcf6b03fa98f07df10332fb49d8c010786ddca6ab34cbba217684f533ff2e";
  };

  buildInputs = [
    bzip2
    cairo
    gdk-pixbuf_unwrapped
    glib
    gobject-introspection
    libcroco
    libgsf
    libxml2
    pango
    vala
  ];

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
    sed -i gdk-pixbuf-loader/Makefile \
      -e "s#gdk_pixbuf_moduledir = .*#gdk_pixbuf_moduledir = $GDK_PIXBUF/loaders#" \
      -e "s#gdk_pixbuf_cache_file = .*#gdk_pixbuf_cache_file = $GDK_PIXBUF/loaders.cache#" \
      -e "s#\$(GDK_PIXBUF_QUERYLOADERS)#GDK_PIXBUF_MODULEDIR=$GDK_PIXBUF/loaders \$(GDK_PIXBUF_QUERYLOADERS)#"
  '';

  meta = with stdenv.lib; {
    description = "Scalable Vector Graphics (SVG) rendering library";
    homepage = https://wiki.gnome.org/Projects/LibRsvg;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
