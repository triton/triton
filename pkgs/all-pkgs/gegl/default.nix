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

let
  versionMajor = "0.3";
  versionMinor = "8";
  version = "${versionMajor}.${versionMinor}";
in
stdenv.mkDerivation rec {
  name = "gegl-${version}";

  src = fetchurl {
    url = "https://download.gimp.org/pub/gegl/${versionMajor}/${name}.tar.bz2";
    sha256 = "06ca9e67a59da026eb941b9d323269d7c19a922f1e478acdd3791a0eef8b229b";
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
