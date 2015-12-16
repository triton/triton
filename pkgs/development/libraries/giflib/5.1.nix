{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "giflib-5.1.1";

  src = fetchurl {
    url = "mirror://sourceforge/giflib/${name}.tar.bz2";
    sha256 = "1z1gzq16sdya8xnl5qjc07634kkwj5m0n3bvvj4v9j11xfn1841r";
  };

  meta = {
    description = "A library for reading and writing gif images";
    platforms = stdenv.lib.platforms.unix;
    license = stdenv.lib.licenses.mit;
    maintainers = with stdenv.lib.maintainers; [ fuuzetsu ];
    branch = "5.1";
  };
}
