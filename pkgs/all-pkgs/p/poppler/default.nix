{ stdenv
, cmake
, fetchTritonPatch
, fetchurl

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
, nspr
, nss
, openjpeg
, qt5
, zlib

, utils ? false
, suffix ? "glib"
}:

# FIXME: gobject-introspection and openjpeg support is not working currently

let
  inherit (stdenv.lib)
    cmFlag;

  # If a is true, return b
  ifDo = a: b:
    if a then
      b
    else
      false;
in

assert (
  suffix == "glib" ||
  suffix == "qt5" ||
  suffix == "utils"
);

stdenv.mkDerivation rec {
  name = "poppler-${suffix}-${version}";
  version = "0.46.0";

  src = fetchurl {
    url = "https://poppler.freedesktop.org/poppler-${version}.tar.xz";
    sha256 = "967d35d13d61dee2fee656b80efef9e388a9e752bc79b7123f15b49c7769e487";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    cairo
    curl
    fontconfig
    freetype
    glib
    #gobject-introspection
    lcms2
    libjpeg
    libpng
    libtiff
    nspr
    nss
    openjpeg
    qt5
    zlib
  ];

  postUnpack = ''
    rm -v $sourceRoot/configure{,.ac}
  '';

  patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "poppler/poppler-datadir_env.patch";
      sha256 = "da3dd1d57a7ef0dcda7442dff2fff5375e249ba85caba9828be4fc51bfa300ff";
    })
  ];

  cmakeFlags = [
    "-DBUILD_CPP_TESTS=OFF"
    "-DBUILD_GTK_TESTS=OFF"
    "-DBUILD_QT4_TESTS=OFF"
    "-DBUILD_QT5_TESTS=OFF"
    (cmFlag "ENABLE_CMS" (ifDo (lcms2 != null) "lcms2"))
    "-DENABLE_CPP=ON"
    (cmFlag "ENABLE_LIBCURL" (curl != null))
    (cmFlag "ENABLE_LIBOPENJPEG" (ifDo (openjpeg != null) "openjpeg2"))
    #"-DENABLE_SPLASH=ON"
    (cmFlag "ENABLE_UTILS" utils)
    "-DENABLE_XPDF_HEADERS=ON"
    (cmFlag "ENABLE_ZLIB" (zlib != null))
    (cmFlag "ENABLE_ZLIB_UNCOMPRESS" (zlib != null))
    (cmFlag "FONT_CONFIGURATION" (ifDo (fontconfig != null) "fontconfig"))
    "-DSPLASH_CMYK=ON"
    "-DUSE_FIXEDPOINT=OFF"
    "-DUSE_FLOAT=ON"
    (cmFlag "WITH_Cairo" (cairo != null))
    (cmFlag "WITH_GLIB" (
      cairo != null
      && glib != null
      && gobject-introspection != null))
    #(cmFlag "WITH_GObjectIntrospection" (gobject-introspection != null))
    #(cmFlag "WITH_GTK" (gtk3 != null))
    "-DWITH_Iconv=ON"
    (cmFlag "WITH_JPEG" (libjpeg != null))
    (cmFlag "WITH_NSS3" (nss != null))
    (cmFlag "WITH_PNG" (libpng != null))
    "-DWITH_Qt4=OFF"
    (cmFlag "WITH_TIFF" (libtiff != null))
  ];

  NIX_CFLAGS_COMPILE = [
    "-Wno-deprecated-declarations"
  ];

  meta = with stdenv.lib; {
    description = "A PDF rendering library";
    homepage = http://poppler.freedesktop.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
