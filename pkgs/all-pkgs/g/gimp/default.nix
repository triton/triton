{ stdenv
, fetchurl
, gettext
, intltool
, pythonPackages

, aalib
, alsa-lib
, atk
, babl
, bzip2
, cairo
, freetype
, fontconfig
, gdk-pixbuf
, gegl
, gexiv2
, ghostscript
, glib
, gtk2
, harfbuzz_lib
, jasper
, lcms2
, libexif
, libgudev
, libjpeg
, libmng
, libmypaint
, libpng
, librsvg
, libtiff
, libwmf
, libzip
, openexr
, pango
, poppler
, xorg
, xz
, zlib
}:

stdenv.mkDerivation rec {
  name = "gimp-2.9.4";

  src = fetchurl rec {
    url = "https://download.gimp.org/pub/gimp/v2.9/${name}.tar.bz2";
    md5Url = "${url}.md5";
    sha256 = "c13ac540fd0bd566d7bdd404afe8a04ec0cb1e547788995cd4e8b218c1057b8a";
  };

  nativeBuildInputs = [
    gettext
    intltool
    pythonPackages.wrapPython
  ];

  buildInputs = [
    aalib
    alsa-lib
    atk
    babl
    bzip2
    cairo
    freetype
    fontconfig
    gdk-pixbuf
    gegl
    gexiv2
    ghostscript
    glib
    gtk2
    harfbuzz_lib
    jasper
    lcms2
    libexif
    libgudev
    libjpeg
    libmng
    libmypaint
    libpng
    librsvg
    libtiff
    libwmf
    libzip
    openexr
    pango
    poppler
    pythonPackages.python
    pythonPackages.pygtk
    xorg.fixesproto
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXcursor
    xorg.libXext
    xorg.libXfixes
    xorg.libXmu
    xorg.libXpm
    xorg.libXt
    xorg.xproto
    xz
    zlib
  ];

  pythonPath = [
    pythonPackages.pygtk
  ];

  postInstall = ''
    wrapPythonPrograms
    ln -sv gimp-2.9 $out/bin/gimp
  '';

  # "screenshot" needs this.
  NIX_LDFLAGS = [
    "-rpath ${xorg.libX11}/lib"
  ];

  meta = with stdenv.lib; {
    description = "The GNU Image Manipulation Program";
    homepage = http://www.gimp.org/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
