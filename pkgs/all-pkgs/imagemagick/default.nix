{ stdenv
, fetchurl
, libtool

, bzip2
, dejavu_fonts
, djvulibre
, fftw
, fontconfig
, freetype
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

with {
  inherit (stdenv)
    isi686
    isx86_64;
  inherit (stdenv.lib)
    enFlag
    wtFlag;
};

assert (isi686 || isx86_64);
assert xorg != null ->
  xorg.libX11 != null &&
  xorg.libXext != null &&
  xorg.libXt != null;

with stdenv.lib;
stdenv.mkDerivation rec {
  name = "imagemagick-${version}";
  version = "6.9.3-3";

  src = fetchurl {
    url = [
      "mirror://imagemagick/ImageMagick-${version}.tar.xz"
      "mirror://imagemagick/releases/ImageMagick-${version}.tar.xz"
    ];
    sha256 = "0j1h29h813gq1q7k5hrcab53sk1ldz4wwkj4y2nm852gcxngf9yi";
  };

  nativeBuildInputs = [
    libtool
  ];

  buildInputs = [
    bzip2
    dejavu_fonts
    djvulibre
    fftw
    fontconfig
    freetype
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
    libtiff
    libwebp
    libxml2
    #opencl
    openexr
    openjpeg
    pango
    perl
    xorg.libX11
    xorg.libXext
    xorg.libXt
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
    (wtFlag "perl" (perl != null) null)
    (wtFlag "perl-options" (perl != null) "PREFIX=\${out}")
    (wtFlag "jemalloc" (jemalloc != null) null)
    #(wtFlag "umem" ( != null) null)
    (wtFlag "bzlib" (bzip2 != null) null)
    (wtFlag "x" (xorg != null) null)
    (wtFlag "zlib" (zlib != null) null)
    #(wtFlag "autotrace" ( != null) null)
    #(wtFlag "dps" ( != null) null)
    (wtFlag "dejavu-font-dir" (dejavu_fonts != null)
      "${dejavu_fonts}/share/fonts/truetype/")
    (wtFlag "fftw" (fftw != null) null)
    (wtFlag "fpx" (libfpx != null) null)
    (wtFlag "djvu" (djvulibre != null) null)
    (wtFlag "fontconfig" (fontconfig != null) null)
    (wtFlag "freetype" (freetype != null) null)
    (wtFlag "gslib" (ghostscript != null) null)
    #(wtFlag "fontpath=" ( != null) null)
    (if (ghostscript != null) then
      "--with-gs-font-dir=${ghostscript}/share/ghostscript/fonts/"
     else
       "--without-gs-font-dir")
    (wtFlag "gvc" (graphviz != null) null)
    (wtFlag "jbig" (jbigkit != null) null)
    (wtFlag "jpeg" (libjpeg != null) null)
    (wtFlag "lcms" (lcms2 != null) null)
    (wtFlag "openjp2" (openjpeg != null) null)
    (wtFlag "lqr" (liblqr1 != null) null)
    (wtFlag "lzma" (xz != null) null)
    (wtFlag "openexr" (openexr != null) null)
    (wtFlag "pango" (pango != null) null)
    (wtFlag "png" (libpng != null) null)
    (wtFlag "rsvg" (librsvg != null) null)
    (wtFlag "tiff" (libtiff != null) null)
    (wtFlag "webp" (libwebp != null) null)
    #(wtFlag "windows-font-dir=" ( != null) null)
    #(wtFlag "wmf" ( != null) null)
    (wtFlag "xml" (libxml2 != null) null)
  ];

  postInstall = ''
    (cd "$out/include" && ln -s ImageMagick* ImageMagick)
  '' + stdenv.lib.optionalString (ghostscript != null) ''
    for la in $out/lib/*.la ; do
      sed -i $la \
        -e 's|-lgs|-L${ghostscript}/lib -lgs|'
    done
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A collection of tools and libraries for many image formats";
    homepage = http://www.imagemagick.org/;
    license = licenses.imagemagick;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
