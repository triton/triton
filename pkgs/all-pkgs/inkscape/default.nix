{ stdenv
, autoreconfHook
, fetchTritonPatch
, fetchurl
, gettext
, intltool
, makeWrapper
, perl
, perlXMLParser
, unzip

, aspell
, boehmgc
, boost
, cairo
, cairomm
, dbus_glib
, fontconfig
, freetype
, glib
, glibmm
, gsl
, gtk2
, gtkmm_2
, gtkspell_2
, imagemagick
, lcms2
, libcdr
, libexif
, libjpeg
, libpng
, librevenge
, libsigcxx
, libvisio
, libwpg
, libxml2
, libxslt
, pango
, poppler
, popt
, python
, pythonPackages
, pyxml
, xorg
, zlib

, boxMakerPlugin ? false
}:

with {
  inherit (stdenv)
    cc;
  inherit (stdenv.lib)
    enFlag
    optional
    optionalString
    wtFlag;
};

let
  boxmaker = fetchurl {
    # http://www.inkscapeforum.com/viewtopic.php?f=11&t=10403
    url = "http://www.keppel.demon.co.uk/111000/files/BoxMaker0.91.zip";
    sha256 = "5c5697f43dc3a95468f61f479cb50b7e2b93379a1729abf19e4040ac9f43a1a8";
  };
in

stdenv.mkDerivation rec {
  name = "inkscape-0.91";

  src = fetchurl {
    url = "https://inkscape.global.ssl.fastly.net/media/resources/file/"
        + "${name}.tar.bz2";
    sha256 = "06ql3x732x2rlnanv0a8aharsnj91j5kplksg574090rks51z42d";
  };

  nativeBuildInputs = [
    autoreconfHook
    gettext
    intltool
    libxslt
    makeWrapper
    perl
    perlXMLParser
  ] ++ optional boxMakerPlugin unzip;

  propagatedBuildInputs = [
    /* Python is used at run-time to execute scripts, e.g.,
       those from the "Effects" menu. */
    python
    pyxml
    pythonPackages.lxml
  ];

  buildInputs = [
    aspell
    boehmgc
    boost
    cairo
    cairomm
    dbus_glib
    fontconfig
    freetype
    glib
    glibmm
    #gnome-vfs
    gsl
    gtk2
    gtkmm_2
    gtkspell_2
    imagemagick
    lcms2
    libcdr
    libexif
    libjpeg
    libpng
    librevenge
    libsigcxx
    libvisio
    libwpg
    libxml2
    pango
    poppler
    popt
    xorg.libX11
    xorg.libXft
    zlib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "d8eca8b601a550b5ec33beced51f73ccb1ce5e51";
      file = "inkscape/inkscape-0.91_pre3-automagic.patch";
      sha256 = "100b94eee2a9f5ffacafe0732735342cb14b873296de1e982e7db24ced31124e";
    })
    (fetchTritonPatch {
      rev = "d8eca8b601a550b5ec33beced51f73ccb1ce5e51";
      file = "inkscape/inkscape-0.91_pre3-desktop.patch";
      sha256 = "016adfaddb1c6c509318430fab9d74ee81f5ce9f71a85ccb4b06d6dc221fff03";
    })
    (fetchTritonPatch {
      rev = "d8eca8b601a550b5ec33beced51f73ccb1ce5e51";
      file = "inkscape/inkscape-0.91_pre3-exif.patch";
      sha256 = "ad4295f73e386ebe89c6f86d456853ceba0b7af24a584b51348b788280145ef0";
    })
    (fetchTritonPatch {
      rev = "d8eca8b601a550b5ec33beced51f73ccb1ce5e51";
      file = "inkscape/inkscape-0.91_pre3-sk-man.patch";
      sha256 = "56e24d84d5217308df178d64214ec13c4b81ba59541cc6f52415f2207825a274";
    })
    (fetchTritonPatch {
      rev = "6fda2c885b725f8d625b85d2e39b7ef2b18e7ff2";
      file = "inkscape/inkscape-0.48.4-epython.patch";
      sha256 = "279c1dd278bf69c69f4ac2351d8d069f08aa444e45c32ccd564f6962304f3cdb";
    })
  ];

  postPatch = ''
    patchShebangs ./share/extensions
  '' +
  /* Clang gets misdetected, so hardcode the right answer */
  optionalString cc.isClang ''
    sed -i src/ui/tool/node.h \
      -e 's/#if __cplusplus >= 201103L/#if true/'
  '' + ''
    sed -i src/extension/implementation/script.cpp \
      -e 's|@EPYTHON@|${python.interpreter}|'
  '';

  preConfigure = (
    /* Tarballs do not contain autogen.sh and unique work-arounds
       are required. Run all commands manually instead of using
       autoreconfHook as it does not handle this situation. */
    /* This autoreconf hack to to work around an issue with autopoint and
       intltool both trying to take ownership of the same file.  Autopoint
       is automatically invoked if AM_GNU_GETTEXT_VERSION or
       AM_GNU_GETTEXT_VERSION exist in configure.ac.  To fix this make
       autoreconf execute intltool in place of autopoint */ ''
      autopoint --force
      AUTOPOINT='intltoolize --automake --copy' autoreconf --force --install --verbose
    '' +
    /* Upstream uses hack for intltool < 0.51.0 in 0.91 */ ''
      sed -i po/Makefile.in.in \
        -e 's/itlocaledir = $(prefix)\/$(DATADIRNAME)\/locale/itlocaledir = $(datarootdir)\/locale/'
    ''
  );

  configureFlags = [
    "--enable-nls"
    "--enable-rpath"
    #"--enable-openmp"
    (enFlag "exif" (libexif != null) null)
    (enFlag "jpeg" (libjpeg != null) null)
    (enFlag "lcms" (lcms2 != null) null)
    "--enable-poppler-cairo"
    "--enable-wpg"
    (enFlag "visio" (libvisio != null) null)
    (enFlag "cdr" (libcdr != null) null)
    "--disable-localinstall"
    "--enable-dbusapi"
    (enFlag "magick" (imagemagick != null) null)
    "--disable-gtk3-experimental"
    "--enable-binreloc"
    "--disable-osxapp"
    #"--with-gnome-vfs"
    "--with-inkjar"
    (wtFlag "gtkspell" (gtkspell_2 != null) null)
    (wtFlag "aspell" (aspell != null) null)
  ];

  makeFlags = [
    # Prevent inkscape from trying to install files in dbus's prefix
    "DBUSSERVICEDIR=\${out}/share/dbus-1/system-services"
  ];

  postInstall = optionalString boxMakerPlugin ''
    mkdir -p $out/share/inkscape/extensions/
    # boxmaker package version 0.91 in a directory called 0.85 ?!??
    unzip ${boxmaker}
    cp -v boxmake-upd-0.85/* $out/share/inkscape/extensions/
    rm -Rvf boxmake-upd-0.85
  '' +
  /* Make sure PyXML modules can be found at run-time. */ ''
    for i in "$out/bin/"* ; do
      wrapProgram "$i" \
        --prefix PYTHONPATH : "$(toPythonPath ${pyxml})" \
        --prefix PYTHONPATH : "$(toPythonPath ${pythonPackages.lxml})" \
        --prefix PATH : ${python}/bin || {
          exit 2
        }
    done
    rm -v "$out/share/icons/hicolor/icon-theme.cache"
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "A SVG based generic vector-drawing program";
    homepage = http://www.inkscape.org;
    license = with licenses; [
      gpl2
      lgpl21
    ];
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
