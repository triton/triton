{ stdenv, fetchurl, pkgconfig, glib, babl, libpng, cairo, libjpeg
, librsvg, pango, bzip2, intltool, gdk_pixbuf, openexr, SDL
, jasper, exiv2 }:

stdenv.mkDerivation rec {
  name = "gegl-0.3.4";

  src = fetchurl {
    url = "https://download.gimp.org/pub/gegl/0.3/${name}.tar.bz2";
    sha256 = "df2e6a0d9499afcbc4f9029c18d9d1e0dd5e8710a75e17c9b1d9a6480dd8d426";
  };

  # needs fonts otherwise  don't know how to pass them
  configureFlags = [ "--disable-docs" ];

  buildInputs = [
    babl glib intltool cairo pango gdk_pixbuf libjpeg openexr librsvg SDL
    jasper exiv2
  ];

  nativeBuildInputs = [ pkgconfig ];

  meta = {
    description = "Graph-based image processing framework";
    homepage = http://www.gegl.org;
    license = stdenv.lib.licenses.gpl3;
  };
}
