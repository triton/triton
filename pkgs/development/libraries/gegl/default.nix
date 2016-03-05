{ stdenv, fetchurl, pkgconfig, glib, babl, libpng, cairo, libjpeg
, librsvg, pango, bzip2, intltool, gdk-pixbuf, openexr, SDL
, jasper, exiv2 }:

stdenv.mkDerivation rec {
  name = "gegl-0.3.4";

  src = fetchurl {
    url = "https://download.gimp.org/pub/gegl/0.3/${name}.tar.bz2";
    sha256 = "1v63vgnhrk4q3fwd62r45v3i9jyp5bwdd8hpgimiwkc5j2kr0ql4";
  };

  # needs fonts otherwise  don't know how to pass them
  configureFlags = [
    "--disable-docs"
  ];

  buildInputs = [
    babl glib intltool cairo pango gdk-pixbuf libjpeg openexr librsvg SDL
    jasper exiv2
  ];

  nativeBuildInputs = [ pkgconfig ];

  meta = {
    description = "Graph-based image processing framework";
    homepage = http://www.gegl.org;
    license = stdenv.lib.licenses.gpl3;
  };
}
