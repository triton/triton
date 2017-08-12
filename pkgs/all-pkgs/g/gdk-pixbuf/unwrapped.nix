{ stdenv
, autoreconfHook
, coreutils
, fetchurl
, gettext
, lib

, glib
, gobject-introspection
, libtiff
, libjpeg
, libpng
, libx11
, jasper
, shared-mime-info

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt
    optionals;

  sources = {
    "2.36" = {
      version = "2.36.8";
      sha256 = "5d68e5283cdc0bf9bda99c3e6a1d52ad07a03364fa186b6c26cfc86fcd396a19";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "gdk-pixbuf-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gdk-pixbuf/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
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
    libx11
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
    "--${boolEn (gobject-introspection != null)}-introspection"
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
    "--${boolWt (libpng != null)}-libpng"
    "--${boolWt (libjpeg != null)}-libjpeg"
    "--${boolWt (libtiff != null)}-libtiff"
    "--${boolWt (jasper != null)}-libjasper"
    "--without-gdiplus"
    "--${boolWt (libx11 != null)}-x11"
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  doCheck = false;

  passthru = {
    inherit (source) version;

    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gdk-pixbuf/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "A library for image loading and manipulation";
    homepage = http://library.gnome.org/devel/gdk-pixbuf/;
    license = licenses.lgpl2Plus;
    maintainers = [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
