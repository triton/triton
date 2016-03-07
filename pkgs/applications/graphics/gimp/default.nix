{ stdenv
, fetchurl
, gettext
, intltool
, pythonPackages

, aalib
, atk
, babl
, bzip2
, cairo
, freetype
, fontconfig
, gdk-pixbuf
, gegl
, gexiv2
, ghostscript
, glib
, gnome2
, gtk2
, harfbuzz
, jasper
, lcms2
, libexif
, libgudev
, libjpeg
, libmng
, libpng
, librsvg
, libtiff
, libwmf
, libzip
, openexr
, pango
, poppler
, xorg
, zlib
, zeroc_ice
}:

stdenv.mkDerivation rec {
  name = "gimp-2.9.2";

  src = fetchurl {
    url = "http://download.gimp.org/pub/gimp/v2.9/${name}.tar.bz2";
    sha256 = "17p2030fynil5qra7k78f0kr61ihfksip3dlz9gy9ck8p0vd9gl5";
  };

  nativeBuildInputs = [
    gettext
    intltool
    pythonPackages.wrapPython
  ];

  buildInputs = [
    aalib
    atk
    babl
    bzip2
    cairo
    freetype
    fontconfig
    gdk-pixbuf
    gegl
    gexiv2
    ghostscript
    glib
    gnome2.libart_lgpl
    gtk2
    harfbuzz
    jasper
    lcms2
    libexif
    libgudev
    libjpeg
    libmng
    libpng
    librsvg
    libtiff
    libwmf
    libzip
    openexr
    pango
    poppler
    pythonPackages.python
    pythonPackages.pygtk
    xorg.libXext
    xorg.libXfixes
    xorg.libXmu
    xorg.libXpm
    zlib
    zeroc_ice
  ];

  pythonPath = [
    pythonPackages.pygtk
  ];

  postInstall = ''
    wrapPythonPrograms
    ln -sv gimp-2.9 $out/bin/gimp
  '';

  # "screenshot" needs this.
  NIX_LDFLAGS = [
    "-rpath ${xorg.libX11}/lib"
  ];

  meta = with stdenv.lib; {
    description = "The GNU Image Manipulation Program";
    homepage = http://www.gimp.org/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
