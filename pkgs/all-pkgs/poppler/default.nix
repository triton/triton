{ stdenv
, fetchpatch
, fetchTritonPatch
, fetchurl
, libiconv

, curl
, cairo
, freetype
, fontconfig
, glib
, gobject-introspection
, libtiff
, lcms2
, libjpeg
, libpng
, openjpeg
, zlib
# QT4
, qt4 ? null
# QT5
, qt5 ? null
, utils ? false
, suffix ? "glib"
}:

with {
  inherit (stdenv.lib)
    enFlag
    optional
    optionals
    wtFlag;
};

assert (
  suffix == "glib" ||
  suffix == "qt4" ||
  suffix == "qt5" ||
  suffix == "utils"
);

stdenv.mkDerivation rec {
  name = "poppler-${suffix}-${version}";
  version = "0.40.0";

  src = fetchurl {
    url = "http://poppler.freedesktop.org/poppler-${version}.tar.xz";
    sha256 = "1bbfxq0aclhaiyj1jcjr583prv5662jvphdqsafgr3q3srwa43dw";
  };

  patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "poppler/poppler-datadir_env.patch";
      sha256 = "da3dd1d57a7ef0dcda7442dff2fff5375e249ba85caba9828be4fc51bfa300ff";
    })
  ];

  configureFlags = [
    "--enable-xpdf-headers"
    "--disable-single-precision"
    "--disable-fixed-point"
    "--enable-cmyk"
    (enFlag "libopenjpeg" (openjpeg != null) null)
    (enFlag "libtiff" (libtiff != null) null)
    (enFlag "zlib" (zlib != null) null)
    (enFlag "libcurl" (curl != null) null)
    (enFlag "libjpeg" (libjpeg != null) null)
    (enFlag "libpng" (libpng != null) null)
    (wtFlag "font-configuration" (fontconfig != null) "fontconfig")
    #"--enable-splash"
    (enFlag "cairo-output" (cairo != null) null)
    (enFlag "poppler-glib" (
      cairo != null &&
      glib != null &&
      gobject-introspection != null) null)
    (enFlag "poppler-qt4" (qt4 != null) null)
    (enFlag "poppler-qt5" (qt5 != null) null)
    (enFlag "poppler-cpp" true null)
    #"gtk-test"
    (enFlag "utils" utils null)
    #"compile-warnings"
    #"cms"
    #"testdatadir"
  ];

  nativeBuildInputs = [
    libiconv
  ];

  buildInputs = [
    cairo
    curl
    fontconfig
    freetype
    glib
    gobject-introspection
    lcms2
    libjpeg
    libpng
    libtiff
    openjpeg
    qt4
    zlib
  ] ++ optional (qt5 != null) qt5.base;

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A PDF rendering library";
    homepage = http://poppler.freedesktop.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
