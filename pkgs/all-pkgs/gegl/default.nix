{ stdenv
, fetchurl
, intltool

, babl
, cairo
, exiv2
, ffmpeg
, gdk-pixbuf
, gexiv2
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
#, v4l_lib
, vala
}:

stdenv.mkDerivation rec {
  name = "gegl-${version}";
  versionMajor = "0.3";
  versionMinor = "6";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "https://download.gimp.org/pub/gegl/${versionMajor}/${name}.tar.bz2";
    sha256 = "70e7fbbc74b9a5d7a8428d49f282855c8b14b4ea7c6a3cb83cb7f2291c6da722";
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
    gexiv2
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
    #v4l_lib
    vala
  ];

  configureFlags = [
    "--disable-docs"
    "--without-mrg"
    "--without-lensfun"
    "--without-sdl"
    "--without-graphviz"
    "--without-lua"
    "--without-libspiro"
    "--without-umfpack"
    "--without-libv4l"  # This is currently broken
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
