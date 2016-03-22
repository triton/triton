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
  versionMajor = "2.33";
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gdk-pixbuf/${versionMajor}/" +
          "gdk-pixbuf-${version}.tar.xz";
    sha256 = "d91ec3ab7d0fcf998d2c38b6725655666e0767e2c462598aea003caee2455929";
  };

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
    "--disable-maintainer-mode"
    # TODO: fix glib to support gio sniffing
    "--disable-gio-sniffing"
    "--enable-largefile"
    "--disable-debug"
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
    "--disable-installed-tests"
    "--disable-always-build-tests"
    "--disable-coverage"
    # Enabling relocations breaks setting loaders.cache path
    "--disable-relocations"
    (wtFlag "libpng" (libpng != null) null)
    (wtFlag "libjpeg" (libjpeg != null) null)
    (wtFlag "libtiff" (libtiff != null) null)
    (wtFlag "libjasper" (jasper != null) null)
    "--without-gdiplus"
    (wtFlag "x11" (xorg != null) null)
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  doCheck = false;

  meta = with stdenv.lib; {
    description = "A library for image loading and manipulation";
    homepage = http://library.gnome.org/devel/gdk-pixbuf/;
    license = licenses.free;
    maintainers = [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
