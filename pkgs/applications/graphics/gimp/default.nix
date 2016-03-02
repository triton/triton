{ stdenv
, fetchurl
, gettext
, intltool
, pythonPackages

, aalib
, atk
, babl
, cairo
, freetype
, fontconfig
, gdk-pixbuf
, gegl
, ghostscript
, glib
, gnome2
, gtk2
, jasper
, lcms2
, libexif
, libjpeg
, libmng
, libpng
, librsvg
, libtiff
, libwmf
, libzip
, pango
, poppler
, xorg
, zlib
}:

stdenv.mkDerivation rec {
  name = "gimp-2.8.16";

  src = fetchurl {
    url = "http://download.gimp.org/pub/gimp/v2.8/${name}.tar.bz2";
    sha256 = "1dsgazia9hmab8cw3iis7s69dvqyfj5wga7ds7w2q5mms1xqbqwm";
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
    cairo
    freetype
    fontconfig
    gdk-pixbuf
    gegl
    ghostscript
    glib
    gnome2.libart_lgpl
    gtk2
    jasper
    lcms2
    libexif
    libjpeg
    libmng
    libpng
    librsvg
    libtiff
    libwmf
    libzip
    pango
    poppler
    pythonPackages.python
    pythonPackages.pygtk
    xorg.libXpm
    zlib
  ];

  pythonPath = [
    pythonPackages.pygtk
  ];

  postInstall = ''
    wrapPythonPrograms
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
