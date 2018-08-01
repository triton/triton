{ stdenv
, fetchurl
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
, libspiro
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

  channel = "0.4";
  version = "${channel}.6";
in
stdenv.mkDerivation rec {
  name = "gegl-${version}";

  src = fetchurl {
    url = "https://download.gimp.org/pub/gegl/${channel}/${name}.tar.bz2";
    multihash = "QmPSjiRoCAUwrf42mUrjKDEXuy15a39xjy4z3zgbJA418e";
    hashOutput = false;
    sha256 = "f8cb45da736131fe29582b74cf6851102ae013bf99c77413a8bcb02e92e57890";
  };

  nativeBuildInputs = [
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
    libspiro
    libtiff
    libwebp
    openexr
    pango
    v4l_lib
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-glibtest"
    "--${boolWt (vala != null)}-vala"
    "--without-mrg"
    "--${boolWt (gexiv2 != null)}-gexiv2"
    "--${boolWt (cairo != null)}-cairo"
    "--${boolWt (pango != null)}-pango"
    "--${boolWt (pango != null)}-pangocairo"
    "--${boolWt (gdk-pixbuf != null)}-gdk-pixbuf"
    "--without-lensfun"
    "--${boolWt (librsvg != null)}-librsvg"
    "--${boolWt (v4l_lib != null)}-libv4l2"
    "--${boolWt (openexr != null)}-openexr"
    "--without-sdl"
    "--${boolWt (libraw != null)}-libraw"
    "--${boolWt (jasper != null)}-jasper"
    "--without-graphviz"
    "--without-lua"
    "--${boolWt (ffmpeg != null)}-libavformat"
    "--${boolWt (v4l_lib != null)}-libv4l"
    "--${boolWt (lcms2 != null)}-lcms"
    "--${boolWt (libspiro != null)}-libspiro"
    "--${boolWt (exiv2 != null)}-exiv2"
    "--without-umfpack"
    "--${boolWt (libtiff != null)}-libtiff"
    "--${boolWt (libwebp != null)}-webp"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
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
