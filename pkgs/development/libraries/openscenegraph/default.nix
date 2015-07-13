{ stdenv, fetchurl, cmake, doxygen, pkgconfig, unzip
, a52dec, coin3d, curl, faad2, ffmpeg, freeglut, freetype, gdal_1_11_2, gdk_pixbuf
, giflib, gtk, jasper, kbproto, lib3ds, libjpeg, libpng, librsvg, libtiff
, libX11, libxml2, libXmu, mesa, openal, poppler, qt4, SDL, xineLib, xproto
, zlib
}:

stdenv.mkDerivation rec {
  name = "openscenegraph-${version}";
  version = "3.2.1";

  src = fetchurl {
    url = "http://www.openscenegraph.org/downloads/developer_releases/OpenSceneGraph-${version}.zip";
    sha256 = "0v9y1gxb16y0mj994jd0mhcz32flhv2r6kc01xdqb4817lk75bnr";
  };

  NIX_CFLAGS_COMPILE="-D__STDC_CONSTANT_MACROS=1";

  cmakeFlags = [
    "-DMATH_LIBRARY="
  ];

  nativeBuildInputs = [ cmake doxygen pkgconfig unzip ];

  buildInputs = [
    a52dec coin3d curl faad2 ffmpeg freeglut freetype gdal_1_11_2 gdk_pixbuf giflib gtk
    jasper kbproto lib3ds libjpeg libpng librsvg libtiff libX11 libxml2 libXmu
    mesa openal poppler qt4 SDL xineLib xproto zlib
  ];

  meta = with stdenv.lib; {
    description = "A high performance 3D graphics toolkit";
    homepage = http://www.openscenegraph.org/;
    license = licenses.free; # OpenSceneGraph Public License - free LGPL-based license
    maintainers = with maintainers; [ raskin ];
    platforms = platforms.linux;
  };
}
