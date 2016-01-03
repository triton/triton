{ stdenv
, fetchurl
, gettext
, intltool
, perl

, atk
, cairo
, cups
, fontconfig
, gdk-pixbuf-core
, gdk-pixbuf
, glib
, gobjectIntrospection
, libxkbcommon
, pango
, xlibsWrapper
, xorg
}:

with {
  inherit (stdenv.lib)
    enFlag
    wtFlag
    optionalString;
};

stdenv.mkDerivation rec {
  name = "gtk+-${version}";
  versionMajor = "2.24";
  versionMinor = "29";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gtk+/${versionMajor}/${name}.tar.xz";
    sha256 = "1f1ifv1ijrda4jx831l24d3ww65v5gf56r464fi11n6k02bcah87";
  };

  configureFlags = [
    (enFlag "shm" (xorg.libXext != null) null)
    (enFlag "xkb" (libxkbcommon != null) null)
    (enFlag "xinerama" (xorg.libXinerama != null) null)
    "--enable-rebuilds"
    "--enable-visibility"
    "--enable-explicit-deps"
    "--enable-glibtest"
    "--enable-modules"
    "--disable-quartz-relocation"
    (enFlag "cups" (cups != null) null)
    (enFlag "papi" false null)
    (enFlag "test-print-backend" (cups != null) null)
    (enFlag "introspection" (gobjectIntrospection != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-man"
    (wtFlag "xinput" (xorg.libXi != null) null)
    (wtFlag "gdktarget" (true) "x11") # add xorg deps
    #"--with-gdktarget=directfb"
    (wtFlag "x" (xorg != null) null)
  ];

  nativeBuildInputs = [
    gettext
    intltool
    perl
  ];

  buildInputs = [
    atk
    cairo
    cups
    fontconfig
    gdk-pixbuf-core
    gdk-pixbuf
    glib
    gobjectIntrospection
    libxkbcommon
    pango
    xorg.inputproto
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXext
    xorg.libXfixes
    xorg.libXdamage
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXrender
  ];

  postInstall = "rm -rf $out/share/gtk-doc";

  enableParallelBuilding = true;

  passthru = {
    gtkExeEnvPostBuild = ''
      rm -v $out/lib/gtk-2.0/2.10.0/immodules.cache
      $out/bin/gtk-query-immodules-2.0 \
        $out/lib/gtk-2.0/2.10.0/immodules/*.so > \
        $out/lib/gtk-2.0/2.10.0/immodules.cache
    ''; # workaround for bug of nix-mode for Emacs */ '';
  };

  meta = with stdenv.lib; {
    description = "A toolkit for creating graphical user interfaces";
    homepage = http://www.gtk.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
