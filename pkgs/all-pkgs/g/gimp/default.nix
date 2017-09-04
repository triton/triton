{ stdenv
, fetchurl
, gettext
, intltool
, lib
, pythonPackages

, aalib
, alsa-lib
, atk
, babl
, bzip2
, cairo
, fixesproto
, freetype
, fontconfig
, gdk-pixbuf
, gegl
, gexiv2
, ghostscript
, glib
, glib-networking
, gtk2
, harfbuzz_lib
, iso-codes
, jasper
, lcms2
, libexif
, libgudev
, libice
, libjpeg
, libmng
, libmypaint
, libpng
, librsvg
, libsm
, libtiff
, libwebp
, libwmf
, libx11
, libxext
, libxfixes
, libxt
, libzip
, openexr
, pango
, poppler
, shared-mime-info
, xorg
, xproto
, xz
, zlib
}:

stdenv.mkDerivation rec {
  name = "gimp-2.9.6";

  src = fetchurl rec {
    url = "https://download.gimp.org/pub/gimp/v2.9/${name}.tar.bz2";
    multihash = "Qman1jmYyoHRXpJLTvRgeyGBrrVUpATSDUtTpafrXEPozS";
    hashOutput = false;
    sha256 = "b46f31d822a33ab416dcb15e33e10b5b98430814fa34f5ea4036230e845dfc9f";
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
    fixesproto
    freetype
    fontconfig
    gdk-pixbuf
    gegl
    gexiv2
    ghostscript
    glib
    glib-networking
    gtk2
    harfbuzz_lib
    iso-codes
    jasper
    lcms2
    libexif
    libgudev
    libice
    libjpeg
    libmng
    libmypaint
    libpng
    librsvg
    libsm
    libtiff
    libwebp
    libwmf
    libx11
    libxext
    libxfixes
    libxt
    libzip
    openexr
    pango
    poppler
    pythonPackages.python
    pythonPackages.pygtk
    shared-mime-info
    xorg.libXcursor
    xorg.libXmu
    xorg.libXpm
    xproto
    xz
    zlib
  ];

  pythonPath = [
    pythonPackages.pygtk
  ];

  configureFlags = [
    "--enable-vector-icons"
  ];

  postInstall = ''
    wrapPythonPrograms
    ln -sv gimp-2.9 $out/bin/gimp
  '';

  NIX_LDFLAGS = [
    # "screenshot" needs this.
    "-rpath ${libx11}/lib"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      md5Urls = map (n: "${n}.md5") src.urls;
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
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
