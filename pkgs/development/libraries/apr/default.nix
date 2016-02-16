{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "apr-1.5.2";

  src = fetchurl {
    url = "mirror://apache/apr/${name}.tar.bz2";
    sha256 = "0ypn51xblix5ys9xy7da3ngdydip0qqh9rdq8nz54w9aq8lys0vx";
  };

  meta = {
    homepage = http://apr.apache.org/;
    description = "The Apache Portable Runtime library";
    platforms = stdenv.lib.platforms.all;
    maintainers = [ stdenv.lib.maintainers.eelco ];
  };
}
