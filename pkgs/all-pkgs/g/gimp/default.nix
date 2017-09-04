{ stdenv
, fetchurl
, gettext
, intltool
, lib
, makeWrapper
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
, gtk_2
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

let
  version = "2.9.6";
  verMajMin =
    # Handle possible double digit minor version
    if builtins.substring 3 1 version == "." then
      builtins.substring 0 3 version  # single
    else
      builtins.substring 0 4 version;  # double
in
stdenv.mkDerivation rec {
  name = "gimp-2.9.6";

  src = fetchurl rec {
    url = "https://download.gimp.org/pub/gimp/v${verMajMin}/${name}.tar.bz2";
    multihash = "Qman1jmYyoHRXpJLTvRgeyGBrrVUpATSDUtTpafrXEPozS";
    hashOutput = false;
    sha256 = "b46f31d822a33ab416dcb15e33e10b5b98430814fa34f5ea4036230e845dfc9f";
  };

  nativeBuildInputs = [
    gettext
    intltool
    makeWrapper
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
    gtk_2
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

  NIX_LDFLAGS = [
    # "screenshot" needs this.
    "-rpath ${libx11}/lib"
  ];

  preBuild = ''
    # Build depends on shared-mime-info
    export XDG_DATA_DIRS="$XDG_DATA_DIRS''${XDG_DATA_DIRS:+:}${shared-mime-info}/share"
  '';

  postInstall = ''
    wrapPythonPrograms
    ln -sv gimp-${verMajMin} $out/bin/gimp
  '';

  preFixup = ''
    wrapProgram $out/bin/gimp-${verMajMin} \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share"
  '';

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
