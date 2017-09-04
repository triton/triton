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
, glib-networking
, gtk2
, harfbuzz_lib
, iso-codes
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
, libwebp
, libwmf
, libzip
, openexr
, pango
, poppler
, shared-mime-info
, xorg
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
    libjpeg
    libmng
    libmypaint
    libpng
    librsvg
    libtiff
    libwebp
    libwmf
    libzip
    openexr
    pango
    poppler
    pythonPackages.python
    pythonPackages.pygtk
    shared-mime-info
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

  configureFlags = [
    "--enable-vector-icons"
  ];

  postInstall = ''
    wrapPythonPrograms
    ln -sv gimp-2.9 $out/bin/gimp
  '';

  # "screenshot" needs this.
  NIX_LDFLAGS = [
    "-rpath ${xorg.libX11}/lib"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      md5Urls = map (n: "${n}.md5") src.urls;
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

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
