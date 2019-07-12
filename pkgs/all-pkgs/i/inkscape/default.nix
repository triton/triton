{ stdenv
, cmake
, fetchurl
, fetchFromGitLab
, gettext
, lib
, libxslt
, makeWrapper
, ninja
, python3

, aspell
, boehm-gc
, boost
, cairo
, cairomm
, dbus
, dbus-glib
, double-conversion
, fontconfig
, freetype
, gdl
, glib
, glibmm
, gsl
, gtk_3
, gtkmm_3
, gtkspell_3
, harfbuzz_lib
, imagemagick
, jemalloc
, lcms2
, libcdr
, libexif
, libjpeg
, libpng
, librevenge
, libsigcxx
, libsoup
, libvisio
, libwpg
, libx11
, libxml2
, pango
, poppler
, xorgproto
, zlib

, channel ? "head"
}:

let
  sources = {
    stable = {
      version = "";
      sha256 = "";
    };
    head = {
      version = "2019-07-09";
      fetchzipversion = 6;
      rev = "68a15264438469e24f1513dd3ee01376ab892a72";
      sha256 = "3f8fa4c049d32271b07d5f20cf94998e5d24b4bde31bf8f85be71015f14075f8";
    };
  };
  source = sources  ."${channel}";
in

stdenv.mkDerivation rec {
  name = "inkscape-${source.version}";

  src =
    if channel != "head" then
      fetchurl {
        url = "https://inkscape.global.ssl.fastly.net/media/resources/file/"
          + "${name}.tar.bz2";
        inherit (source) sha256;
      }
    else
      fetchFromGitLab {
        version = source.fetchzipversion;
        host = "https://gitlab.com";
        owner = "inkscape";
        repo = "inkscape";
        inherit (source) rev sha256;
      };

  nativeBuildInputs = [
    cmake
    gettext
    libxslt
    makeWrapper
    ninja
    python3
  ];

  buildInputs = [
    aspell
    boehm-gc
    boost
    #cairo
    cairomm
    dbus
    dbus-glib
    double-conversion
    fontconfig
    freetype
    gdl
    glib
    #glibmm
    gsl
    gtk_3
    gtkmm_3
    gtkspell_3
    harfbuzz_lib
    #imagemagick
    jemalloc
    lcms2
    libcdr
    libexif
    libjpeg
    libpng
    librevenge
    libsigcxx
    libsoup
    libvisio
    libwpg
    libx11
    libxml2
    pango
    poppler
    xorgproto
    zlib
  ];

  postPatch = ''
    grep -q 'Cairo::FORMAT_ARGB32' src/ui/dialog/ocaldialogs.cpp
    sed -i src/ui/dialog/ocaldialogs.cpp \
      -e 's/Cairo::FORMAT_ARGB32/Cairo::Surface::Format::ARGB32/'
    grep -q 'Cairo::FORMAT_RGB24' src/ui/widget/ink-color-wheel.cpp
    sed -i src/ui/widget/ink-color-wheel.cpp \
      -e 's/Cairo::FORMAT_RGB24/Cairo::Surface::Format::RGB24/g'
    grep -q 'Cairo::FILL_RULE_WINDING' src/ui/widget/preferences-widget.cpp
    sed -i src/ui/widget/preferences-widget.cpp \
      -e 's/Cairo::FILL_RULE_WINDING/Cairo::Context::FillRule::WINDING/'
  '' + ''
    patchShebangs share/extensions/
  '';

  cmakeFlags = [
    "-DENABLE_POPPLER=OFF"  # FIXME
    "-DWITH_DBUS=ON"
    "-DWITH_IMAGE_MAGICK=OFF"  # FIXME
    "-DWITH_GRAPHICS_MAGICK=OFF"  # FIXME
    "-DWITH_JEMALLOC=ON"
  ];

  postInstall = ''
    wrapProgram $out/bin/inkscape \
      --prefix PATH ':' '${python3}/bin'
  '';

  meta = with lib; {
    description = "A SVG based generic vector-drawing program";
    homepage = http://www.inkscape.org;
    license = with licenses; [
      gpl2
      lgpl21
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
