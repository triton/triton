{ stdenv, lib, fetchurl, fetchpatch, pkgconfig, libiconv, libintlOrEmpty
, zlib, curl, cairo, freetype, fontconfig, lcms, libjpeg, openjpeg
, minimal ? false, qt4Support ? false, qt4 ? null, qt5Support ? false, qtbase ? null
, utils ? false, suffix ? "glib"
}:

let # beware: updates often break cups_filters build
  version = "0.39.0";
  sha256 = "1fbvw4fb9jrj63l1ihfslkqxikvhx8yy9i2mfwfix963m7pmpmxg";
in
stdenv.mkDerivation rec {
  name = "poppler-${suffix}-${version}";

  src = fetchurl {
    url = "${meta.homepage}/poppler-${version}.tar.xz";
    inherit sha256;
  };

  patches = [ ./datadir_env.patch ];

  # TODO: reduce propagation to necessary libs
  propagatedBuildInputs = with lib;
    [ zlib freetype fontconfig libjpeg lcms curl openjpeg ]
    ++ optional (!minimal) cairo
    ++ optional qt4Support qt4
    ++ optional qt5Support qtbase;

  nativeBuildInputs = [ pkgconfig libiconv ] ++ libintlOrEmpty;

  configureFlags = with lib;
    [
      "--enable-xpdf-headers"
      "--enable-libcurl"
      "--enable-zlib"
    ]
    ++ optionals minimal [ "--disable-poppler-glib" "--disable-poppler-cpp" ]
    ++ optional (!utils) "--disable-utils";

  enableParallelBuilding = true;

  meta = with lib; {
    homepage = http://poppler.freedesktop.org/;
    description = "A PDF rendering library";

    longDescription = ''
      Poppler is a PDF rendering library based on the xpdf-3.0 code base.
    '';

    license = licenses.gpl2;
    platforms = platforms.all;
    maintainers = with maintainers; [ ttuegel ];
  };
}
