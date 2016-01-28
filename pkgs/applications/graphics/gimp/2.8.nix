{ stdenv, fetchurl, pkgconfig, intltool, babl, gegl, gtk2, glib, gdk_pixbuf
, pango, cairo, freetype, fontconfig, lcms, libpng, libjpeg, poppler, libtiff
, webkit, libmng, librsvg, libwmf, zlib, libzip, ghostscript, aalib, jasper
, python, pygtk, libart_lgpl, libexif, gettext, xorg, wrapPython, atk }:

stdenv.mkDerivation rec {
  name = "gimp-2.8.16";

  src = fetchurl {
    url = "http://download.gimp.org/pub/gimp/v2.8/${name}.tar.bz2";
    sha256 = "1dsgazia9hmab8cw3iis7s69dvqyfj5wga7ds7w2q5mms1xqbqwm";
  };

  nativeBuildInputs = [ pkgconfig intltool gettext wrapPython ];

  buildInputs = [
    babl gegl gtk2 glib gdk_pixbuf pango cairo
    freetype fontconfig lcms libpng libjpeg poppler libtiff webkit
    libmng librsvg libwmf zlib libzip ghostscript aalib jasper
    python pygtk libart_lgpl libexif xorg.libXpm atk
  ];

  pythonPath = [ pygtk ];

  postInstall = ''
    wrapPythonPrograms
  '';

  # "screenshot" needs this.
  NIX_LDFLAGS = "-rpath ${xorg.libX11}/lib"
    + stdenv.lib.optionalString stdenv.isDarwin " -lintl";

  meta = {
    description = "The GNU Image Manipulation Program";
    homepage = http://www.gimp.org/;
    license = stdenv.lib.licenses.gpl3Plus;
    platforms = stdenv.lib.platforms.unix;
  };
}
