{ stdenv
, autoreconfHook
, fetchurl
, intltool
, lib

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
  version = "${channel}.26";
in
stdenv.mkDerivation rec {
  name = "gegl-${version}";

  src = fetchurl {
    url = "https://download.gimp.org/pub/gegl/${channel}/${name}.tar.bz2";
    multihash = "QmeiUWR7ewiY2eThcAXu1o4ehKakz3jcHR8VEZuJP2R91Z";
    hashOutput = false;
    sha256 = "6eff9844c4776546213f5e187e1ebcf646d0d4804ebc6d3dd62003cd4d5c3fa9";
  };

  nativeBuildInputs = [
    # Pre-generated autoconf/automake files are outdated and fail
    # to detect libv4l & ffmpeg correctly.
    autoreconfHook
    intltool
    vala
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
    "--${boolWt (gexiv2 != null)}-gexiv2"
    "--${boolWt (cairo != null)}-cairo"
    "--${boolWt (pango != null)}-pango"
    "--${boolWt (pango != null)}-pangocairo"
    "--${boolWt (gdk-pixbuf != null)}-gdk-pixbuf"
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
    "--${boolWt (ffmpeg != null)}-libavformat"
    #"--${boolWt (v4l_lib != null)}-libv4l"
    "--without-libv4l"
    "--${boolWt (lcms2 != null)}-lcms"
    "--without-libspiro"
    "--${boolWt (exiv2 != null)}-exiv2"
    "--without-exit2"
    "--without-umfpack"
    "--${boolWt (libtiff != null)}-libtiff"
    "--${boolWt (libwebp != null)}-webp"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha1Urls = map (n: "${n}/../SHA1SUMS") src.urls;
      sha256Urls = map (n: "${n}/../SHA256SUMS") src.urls;
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

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
