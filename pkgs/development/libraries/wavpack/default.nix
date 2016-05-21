{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "wavpack-${version}";
  version = "4.80.0";

  preConfigure = ''
    sed -i '2iexec_prefix=@exec_prefix@' wavpack.pc.in
  '';

  src = fetchurl {
    url = "http://www.wavpack.com/${name}.tar.bz2";
    sha256 = "79182ea75f7bd1ca931ed230062b435fde4a4c2e0dbcad048007bd1ef1e66be9";
  };

  meta = with stdenv.lib; {
    description = "Hybrid audio compression format";
    homepage    = http://www.wavpack.com/;
    license     = licenses.bsd3;
    platforms   = platforms.all;
    maintainers = with maintainers; [ codyopel ];
  };
}
