{ stdenv
, fetchurl

, bzip2
, dejavu-fonts
, djvulibre
, fftw_single
, fontconfig
, freetype
, fftw_double
, ghostscript
, graphviz
, jbigkit
, jemalloc
, lcms2
, libfpx
, libjpeg
, liblqr1
, libpng
, librsvg
, libtiff
, libtool
, libwebp
, libxml2
#, opencl
, openexr
, openjpeg
, pango
, perl
, xorg
, xz
, zlib
}:

let
  inherit (stdenv.lib)
    boolString
    boolWt
    optionalString;

  # Use stable patch releases, e.g. -9 or -10
  version = "7.0.2-10";
in

assert xorg != null ->
  xorg.libX11 != null
  && xorg.libXext != null
  && xorg.libXt != null;

stdenv.mkDerivation rec {
  name = "imagemagick-${version}";

  src = fetchurl {
    urls = map (n: "${n}/ImageMagick-${version}.tar.xz") [
      "mirror://imagemagick/releases"
      "mirror://imagemagick"
    ];
    allowHashOutput = false;
    sha256 = "dad306bfd7730e1665c6fdb6eb478fb2c41e2db71ab56451bbaebe9df546b1d2";
  };

  buildInputs = [
    bzip2
    dejavu-fonts
    djvulibre
    fftw_single
    fontconfig
    freetype
    fftw_double
    ghostscript
    graphviz
    jbigkit
    jemalloc
    lcms2
    libfpx
    libjpeg
    liblqr1
    libpng
    librsvg
    libtool
    libtiff
    libwebp
    libxml2
    #opencl
    openexr
    openjpeg
    pango
    perl
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXext
    xorg.libXt
    xorg.xextproto
    xorg.xproto
    xz
    zlib
  ];

  configureFlags = [
    "--enable-reproducible-build"
    #"--enable-ld-version-script"
    #"--enable-bounds-checking"
    "--disable-osx-universal-binary"
    #"openmp"
    #(enFlag "opencl" (opencl != null) null)
    "--enable-largefile"
    #"--enable-delegate-build"
    "--disable-deprecated"
    #"--enable-installed"
    "--enable-cipher"
    #"--enable-zero-configuration"
    #"--enable-hdri" # This breaks some dependencies
    "--enable-assert"
    "--disable-maintainer-mode"
    #--enable-hugepages
    #--enable-ccmalloc
    #--enable-efence
    "--disable-prof"
    "--disable-gprof"
    "--disable-gcov"
    #--disable-assert
    "--disable-docs"
    #--with-gnu-ld
    #--with-dmalloc
    #--with-gcc-arch=
    "--with-threads"
    "--with-modules"
    "--with-frozenpaths"
    "--with-magick-plus-plus"
    "--${boolWt (perl != null)}-perl"
    "--${boolWt  (perl != null)}-perl-options${
      boolString (perl != null) "=PREFIX=\${out}" ""}"
    "--${boolWt (jemalloc != null)}-jemalloc"
    #"--${boolWt ( != null)}-umem"
    "--${boolWt (bzip2 != null)}-bzlib"
    "--${boolWt (xorg != null)}-x"
    "--${boolWt (zlib != null)}-zlib"
    #"--${boolWt ( != null)}-autotrace"
    #"--${boolWt ( != null)}-dps"
    "--${boolWt (dejavu-fonts != null)}-dejavu-font-dir${
      boolString (dejavu-fonts != null) "=${dejavu-fonts}/share/fonts/truetype/" ""}"
    "--${boolWt (fftw_single != null)}-fftw"
    "--${boolWt (libfpx != null)}-fpx"
    "--${boolWt (djvulibre != null)}-djvu"
    "--${boolWt (fontconfig != null)}-fontconfig"
    "--${boolWt (freetype != null)}-freetype"
    "--${boolWt (ghostscript != null)}-gslib"
    #"--${boolWt }-fontpath=" ( != null) null)
    "--${boolWt (ghostscript != null)}-gs-font-dir${
      boolString (ghostscript != null) "=${ghostscript}/share/ghostscript/fonts/" ""}"
    "--${boolWt (graphviz != null)}-gvc"
    "--${boolWt (jbigkit != null)}-jbig"
    "--${boolWt (libjpeg != null)}-jpeg"
    "--${boolWt (lcms2 != null)}-lcms"
    "--${boolWt (openjpeg != null)}-openjp2"
    "--${boolWt (liblqr1 != null)}-lqr"
    "--${boolWt (xz != null)}-lzma"
    "--${boolWt (openexr != null)}-openexr"
    "--${boolWt (pango != null)}-pango"
    "--${boolWt (libpng != null)}-png"
    "--${boolWt (librsvg != null)}-rsvg"
    "--${boolWt (libtiff != null)}-tiff"
    "--${boolWt (libwebp != null)}-webp"
    #"--${boolWt ( != null)}-windows-font-dir="
    #"--${boolWt ( != null)}-wmf"
    "--${boolWt (libxml2 != null)}-xml"
  ];

  postInstall = ''
    (cd "$out/include" && ln -s ImageMagick* ImageMagick)
  '' + optionalString (ghostscript != null) ''
    for la in $out/lib/*.la ; do
      sed -i $la \
        -e 's|-lgs|-L${ghostscript}/lib -lgs|'
    done
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "D827 2EF5 1DA2 23E4 D05B  4669 89AB 63D4 8277 377A";
    };
  };

  meta = with stdenv.lib; {
    description = "A collection of tools and libraries for many image formats";
    homepage = http://www.imagemagick.org/;
    license = licenses.imagemagick;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
