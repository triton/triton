{ stdenv
, autoreconfHook
, coreutils
, fetchurl
, gettext

, glib
, gobject-introspection
, libtiff
, libjpeg
, libpng
, jasper
, shared_mime_info
, xorg
}:

with {
  inherit (stdenv.lib)
    enFlag
    optionals
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "gdk-pixbuf-core-${version}";
  versionMajor = "2.32";
  versionMinor = "3";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gdk-pixbuf/${versionMajor}/" +
          "gdk-pixbuf-${version}.tar.xz";
    sha256 = "0cfh87aqyqbfcwpbv1ihgmgfcn66il5q2n8yjyl8gxkjmkqp2rrb";
  };

  postPatch =
  /* The configure script only tests glib for mimetype detection
     support if --enable-gio-sniffing=auto, this patches it to
     run the test and explicitly fail if glib isn't configured
     correctly. */ ''
    sed -i configure.ac \
      -e '/x$enable_gio_sniffing/ s/xauto/xyes/' \
      -e 's|\[gio_can_sniff=no\]|\[gio_can_sniff=no, AC_MSG_ERROR(gio cannot determine mimetype)\]|'
  '';

  configureFlags = [
    # TODO: fix glib to support gio sniffing
    "--disable-gio-sniffing"
    "--enable-rebuilds"
    "--enable-nls"
    "--enable-rpath"
    "--enable-glibtest"
    "--enable-modules"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-man"
    "--enable-Bsymbolic"
    "--enable-installed-tests"
    "--enable-always-build-tests"
    "--disable-coverage"
    # Enabling relocations breaks setting loaders.cache path
    "--disable-relocations"
    (wtFlag "libpng" (libpng != null) null)
    (wtFlag "libjpeg" (libjpeg != null) null)
    (wtFlag "libjasper" (jasper != null) null)
    "--with-gdiplus"
    (wtFlag "x11" (xorg != null) null)
  ];

  nativeBuildInputs = [
    autoreconfHook
    coreutils
    gettext
  ];

  buildInputs = [
    glib
    gobject-introspection
    jasper
    libjpeg
    libpng
    libtiff
  ] ++ optionals (xorg != null) [
    xorg.libX11
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  doCheck = false;
  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A library for image loading and manipulation";
    homepage = http://library.gnome.org/devel/gdk-pixbuf/;
    maintainers = [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
