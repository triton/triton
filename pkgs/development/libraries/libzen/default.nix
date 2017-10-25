{ stdenv, fetchurl, automake, autoconf, libtool }:

let version = "0.4.33"; in

stdenv.mkDerivation {
  name = "libzen-${version}";
  src = fetchurl {
    url = "http://mediaarea.net/download/source/libzen/${version}/libzen_${version}.tar.bz2";
    sha256 = "0py5iagajz6m5zh26svkjyy85k1dmyhi6cdbmc3cb56a4ix1k2d2";
  };

  nativeBuildInputs = [ automake autoconf libtool ];
  configureFlags = [ "--enable-shared" ];

  srcRoot = "./ZenLib/Project/GNU/Library/";

  preConfigure = "sh autogen.sh";

  # FIXME
  buildDirCheck = false;

  meta = {
    description = "Shared library for libmediainfo and mediainfo";
    homepage = http://mediaarea.net/;
    license = stdenv.lib.licenses.bsd2;
    platforms = stdenv.lib.platforms.all;
    maintainers = [ stdenv.lib.maintainers.devhell ];
  };
}
