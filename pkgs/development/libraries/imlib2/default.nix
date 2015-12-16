{ stdenv, fetchurl, xlibsWrapper, libjpeg, libtiff, giflib, libpng, bzip2, pkgconfig, libid3tag }:

stdenv.mkDerivation rec {
  name = "imlib2-1.4.7";

  src = fetchurl {
    url = "mirror://sourceforge/enlightenment/${name}.tar.bz2";
    sha256 = "00a7jbwj10x3jcvxa5rplnkvhv35gv9rb400zy636zdd4g737mrm";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ xlibsWrapper libjpeg libtiff giflib libpng bzip2 libid3tag ];

  preConfigure = ''
    substituteInPlace imlib2-config.in \
      --replace "@my_libs@" ""
  '';

  # Do not build amd64 assembly code on Darwin, because it fails to compile
  # with unknow directive errors
  configureFlags = if stdenv.isDarwin then [ "--enable-amd64=no" ] else null;

  meta = {
    description = "Image manipulation library";

    longDescription = ''
      This is the Imlib 2 library - a library that does image file loading and
      saving as well as rendering, manipulation, arbitrary polygon support, etc.
      It does ALL of these operations FAST. Imlib2 also tries to be highly
      intelligent about doing them, so writing naive programs can be done
      easily, without sacrificing speed.
    '';

    license = stdenv.lib.licenses.free;
    platforms = stdenv.lib.platforms.unix;
    maintainers = with stdenv.lib.maintainers; [ spwhitt ];
  };
}
