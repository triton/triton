{ fetchurl, stdenv }:

stdenv.mkDerivation rec {
  name = "libidn-1.32";

  src = fetchurl {
    url = "mirror://gnu/libidn/${name}.tar.gz";
    sha256 = "1xf4hphhahcjm2xwx147lfpsavjwv9l4c2gf6hx71zxywbz5lpds";
  };

  doCheck = true;

  meta = {
    homepage = http://www.gnu.org/software/libidn/;
    description = "Library for internationalized domain names";
    license = stdenv.lib.licenses.lgpl2Plus;
    platforms = stdenv.lib.platforms.all;
  };
}
