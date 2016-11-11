{ stdenv
, autoreconfHook
, fetchurl
, intltool
, lib

, babl
, cairo
, exiv2
, ffmpeg_2
, gdk-pixbuf_unwrapped
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
, v4l_lib
, vala
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (lib)
    boolEn
    boolWt
    elem
    platforms;

  channel = "0.3";
  version = "${channel}.10";
in
stdenv.mkDerivation rec {
  name = "gegl-${version}";

  src = fetchurl {
    url = "https://download.gimp.org/pub/gegl/${channel}/${name}.tar.bz2";
    sha256 = "26b4d6d0a8edb358ca2fbc097f9f97eec9d74e0ffe42f89fa1aff201728023d9";
  };

  nativeBuildInputs = [
    # Pre-generated autoconf/automake files are outdated and fail
    # to detect libv4l & ffmpeg correctly.
    autoreconfHook
    intltool
  ];

  buildInputs = [
    babl
    cairo
    #exiv2
    ffmpeg_2
    gdk-pixbuf_unwrapped
    #gexiv2
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
    "--disable-maintainer-mode"
    "--enable-largefile"
    "--disable-debug"
    "--disable-profile"
    "--disable-docs"
    "--${boolEn (elem targetSystem platforms.x86-all)}-mmx"
    "--${boolEn (elem targetSystem platforms.x86-all)}-sse"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-glibtest"
    "--enable-nls"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-workshop"
    "--${boolEn (vala != null)}-vala"
    "--without-mrg"
    # Requres --with-mrg
    #"--${boolWt (gexiv2 != null && mrg != null)}-gexiv2"
    "--without-gexiv2"
    "--${boolWt (cairo != null)}-cairo"
    "--${boolWt (pango != null)}-pango"
    "--${boolWt (pango != null)}-pangocairo"
    "--${boolWt (gdk-pixbuf_unwrapped != null)}-gdk-pixbuf"
    "--without-lensfun"
    "--${boolWt (librsvg != null)}-librsvg"
    # Requires --with-libv4l
    #"--${boolWt (v4l_lib != null)}-libv4l2"
    "--without-libv4l2"
    "--${boolWt (openexr != null)}-openexr"
    "--without-sdl"
    "--${boolWt (libraw != null)}-libraw"
    "--${boolWt (jasper != null)}-jasper"
    "--without-graphviz"
    "--without-lua"
    "--${boolWt (ffmpeg_2 != null)}-libavformat"
    #"--${boolWt (v4l_lib != null)}-libv4l"
    "--without-libv4l"
    "--${boolWt (lcms2 != null)}-lcms"
    "--without-libspiro"
    #"--${boolWt (exiv2 != null)}-exiv2"
    "--without-exit2"
    "--without-umfpack"
    "--${boolWt (libtiff != null)}-libtiff"
    "--${boolWt (libwebp != null)}-webp"
  ];

  meta = with lib; {
    description = "Graph-based image processing framework";
    homepage = http://www.gegl.org;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
