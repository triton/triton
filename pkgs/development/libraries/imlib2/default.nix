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

  meta = {
    description = "Image manipulation library";

    license = stdenv.lib.licenses.free;
    platforms = stdenv.lib.platforms.unix;
    maintainers = with stdenv.lib.maintainers; [ spwhitt ];
  };
}
