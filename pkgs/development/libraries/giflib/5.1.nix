{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "giflib-5.1.2";

  src = fetchurl {
    url = "mirror://sourceforge/giflib/${name}.tar.bz2";
    sha256 = "0z1adsza46q84chkxwr6x8ph11k117k8nywkzwar6bxhqf2a1h3n";
  };

  meta = {
    description = "A library for reading and writing gif images";
    platforms = stdenv.lib.platforms.unix;
    license = stdenv.lib.licenses.mit;
    maintainers = with stdenv.lib.maintainers; [ fuuzetsu ];
    branch = "5.1";
  };
}
