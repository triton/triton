{ stdenv
, fetchurl
, intltool

, babl
, cairo
, exiv2
, ffmpeg
, gdk-pixbuf
, glib
, gobject-introspection
, jasper
, json-glib
, lcms2
, libjpeg
, libpng
, libraw
, librsvg
, libtiff
, libwebp
, openexr
, pango
, v4l_lib
, vala
}:

stdenv.mkDerivation rec {
  name = "gegl-0.3.4";

  src = fetchurl {
    url = "https://download.gimp.org/pub/gegl/0.3/${name}.tar.bz2";
    sha256 = "1v63vgnhrk4q3fwd62r45v3i9jyp5bwdd8hpgimiwkc5j2kr0ql4";
  };

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    babl
    cairo
    exiv2
    ffmpeg
    gdk-pixbuf
    glib
    gobject-introspection
    jasper
    json-glib
    lcms2
    libjpeg
    libpng
    libraw
    librsvg
    libtiff
    libwebp
    openexr
    pango
    v4l_lib
    vala
  ];

  configureFlags = [
    "--disable-docs"
    "--without-mrg"
    "--without-gexiv2"
    "--without-lensfun"
    "--without-sdl"
    "--without-graphviz"
    "--without-lua"
    "--without-libspiro"
    "--without-umfpack"
  ];

  meta = with stdenv.lib; {
    description = "Graph-based image processing framework";
    homepage = http://www.gegl.org;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
