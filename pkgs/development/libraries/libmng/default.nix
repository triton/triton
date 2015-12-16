{ stdenv, fetchurl, zlib, libpng, libjpeg, lcms2 }:

stdenv.mkDerivation rec {
  name = "libmng-2.0.3";

  src = fetchurl {
    url = "mirror://sourceforge/libmng/${name}.tar.xz";
    sha256 = "1lvxnpds0vcf0lil6ia2036ghqlbl740c4d2sz0q5g6l93fjyija";
  };

  propagatedBuildInputs = [ zlib libpng libjpeg lcms2 ];

  meta = {
    description = "Reference library for reading, displaying, writing and examining Multiple-Image Network Graphics";
    homepage = http://www.libmng.com;
    license = stdenv.lib.licenses.zlib;
    maintainers = with stdenv.lib.maintainers; [ marcweber urkud ];
    hydraPlatforms = stdenv.lib.platforms.linux;
  };
}
